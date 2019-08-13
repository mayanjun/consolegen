package ${packageName}.business;

import ${packageName}.StatusCode;
import ${packageName}.bean.User;
import ${packageName}.config.AppConfig;
import ${packageName}.interceptor.SessionManager;
import ${packageName}.util.ParametersBuilder;
import org.apache.commons.lang3.StringUtils;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.xssf.usermodel.*;
import org.mayanjun.core.Assert;
import org.mayanjun.core.ServiceException;
import org.mayanjun.myjack.api.entity.EditableEntity;
import org.mayanjun.myjack.api.entity.EntityBean;
import org.mayanjun.myjack.api.query.Query;
import org.mayanjun.myjack.api.query.QueryBuilder;
import org.mayanjun.myjack.api.query.SortDirection;
import org.mayanjun.myjack.dao.BasicDAO;
import org.mayanjun.myjack.generator.AnnotationHelper;
import org.mayanjun.myjack.generator.AnnotationHolder;
import org.mayanjun.myjack.util.ClassUtils;
import org.mayanjun.myrest.session.SessionUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.support.TransactionTemplate;

import java.awt.*;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * 通用的CRUD处理器。无特殊需求的情况下，子类只需要继承即可。
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
public abstract class BaseBusiness<T extends EntityBean> {

	private static final Logger LOG = LoggerFactory.getLogger(BaseBusiness.class);

	public static final int PAGE_SIZE = 10;

	public static final String BEAN_ID_SEPARATOR = "_";

	private Class<T> beanType = null;

	@Autowired
	protected BasicDAO service;

	@Autowired
	protected AppConfig config;

	@Autowired
    private FileBusiness fileBusiness;

	protected TransactionTemplate transaction() {
		return service.getDataBaseRouter().getDatabaseSession().getTransaction();
	}

	@Autowired
	private SessionManager sessionManager;

	public long count(ParametersBuilder parametersBuilder) {
		QueryBuilder<T> builder = renderSearchEngine(parametersBuilder);
		return service.count(builder.build());
	}

	/**
	 * 查询实体列表
	 * @return
	 */
	public List<T> list(int page,int pageSize, ParametersBuilder parametersBuilder) {
		QueryBuilder<T> builder = renderSearchEngine(parametersBuilder);

		// set page
		if (page < 0) page = 1;
		if (pageSize < 0) pageSize = PAGE_SIZE;
		page = (page - 1) * pageSize;
		builder.limit(page, pageSize);

		builder.orderBy("id", SortDirection.DESC);

		List<T> list = doQuery(builder);
		return list;
	}

	public String exportData(ParametersBuilder parametersBuilder) {
        try {
            QueryBuilder<T> builder = renderSearchEngine(parametersBuilder);
            builder.orderBy("id", SortDirection.DESC);
            List<T> list = doQuery(builder);
            Assert.notEmpty(list, "暂无数据需要导出");

            String fileName = exportFileName(parametersBuilder);
            File localFile = fileBusiness.localFile(fileName);
            // 写Excel
            XSSFWorkbook workbook = new XSSFWorkbook();
            XSSFCellStyle cellStyle = workbook.createCellStyle();

            XSSFCellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setBorderBottom(BorderStyle.DOUBLE);
            headerStyle.setBottomBorderColor(new XSSFColor(new Color(100,100,100)));
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setFillForegroundColor(new XSSFColor(new Color(197, 232, 239)));


            XSSFCellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBottomBorderColor(new XSSFColor(new Color(180,180,180)));
            dataStyle.setVerticalAlignment(VerticalAlignment.CENTER);


            XSSFDataFormat format = workbook.createDataFormat();
            cellStyle.setDataFormat(format.getFormat("yyyy-MM-dd hh:mm:ss"));

            XSSFSheet spreadsheet = workbook.createSheet("数据表");
            String headers[] = formatExportEntityHeaders();
            if (headers != null && headers.length > 0) {
                XSSFRow row = spreadsheet.createRow(0);
                row.setHeight((short) (256 * 2));
                for (int i = 0; i < headers.length; i++) {
                    XSSFCell cell = row.createCell(i);
                    cell.setCellValue(headers[i]);
                    spreadsheet.setColumnWidth(i, 256*20+184);
                    cell.setCellStyle(headerStyle);
                }
            }

            int count = 1;
            for (T e : list) {
                XSSFRow row = spreadsheet.createRow(count++);
                row.setHeight((short) (256 * 1.5));
                String values[] = formatExportEntity(e);
                if (values != null && values.length > 0) {
                    for (int i = 0; i < values.length; i++) {
                        XSSFCell cell = row.createCell(i);
                        cell.setCellValue(values[i]);
                        cell.setCellStyle(dataStyle);
                    }
                }
            }

            OutputStream out = new FileOutputStream(localFile);
            workbook.write(out);
            out.close();
            workbook.close();
            LOG.info("Dara export done: file={}", fileName);
            return fileName;
        } catch (ServiceException e) {
            throw e;
        } catch (Exception e) {
            LOG.error("Export file error", e);
            throw new ServiceException("文件导出失败");
        }
    }

    /**
     * 返回导出文件的文件名
     * @param parametersBuilder
     * @return
     */
    protected String exportFileName(ParametersBuilder parametersBuilder) {
        return new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + ".xlsx";
    }

    /**
     * 格式化实体
     * @param entity
     * @return
     */
    protected String [] formatExportEntity(T entity) {
        return null;
    }

    protected String [] formatExportEntityHeaders() {
        return null;
    }

	protected void renderListAllBuilder(QueryBuilder<T> builder) {
		builder.orderBy("id", SortDirection.DESC);
	}

	public List<T> listAll(ParametersBuilder parametersBuilder) {
		QueryBuilder<T> builder = renderSearchEngine(parametersBuilder);
		renderListAllBuilder(builder);
		return doQuery(builder);
	}

	protected T newInstance(Long id) {
		Class<T> t = getBeanType();
		try {
			T bean = t.getConstructor(Long.class).newInstance(id);
			return bean;
		} catch (Exception e) {
			LOG.error("Can not create instance: " + t, e);
			throw new ServiceException(e.getMessage());
		}
	}

	/**
	 * 对外提供通过ID查询实体服务
	 * @param id
	 * @return
	 */
	public T get(long id) {
		T bean = newInstance(id);
		return doGet(bean);
	}

	protected T doGet(T bean) {
		return service.getExclude(bean);
	}

	/**
	 * 获取实际参数类型
	 * @return
	 */
	protected Class<T> getBeanType() {
		if(this.beanType != null) return beanType;
		beanType = (Class<T>) ClassUtils.getFirstParameterizedType(this.getClass());
		return beanType;
	}

	/**
	 * 对外删除实体服务
	 * @param ids
	 */
	public void delete(Long ids[]) {
		// 逐出缓存
		Query<T> query = QueryBuilder.custom(getBeanType()).andIn("id", ids).build();
		service.delete(query);
	}

	/**
	 * 处理真正的保存逻辑
	 * @param bean
	 * @return
	 */
	protected long doSave(T bean) {
		return service.save(bean);
	}

	/**
	 * 处理真正的更新逻辑
	 * @param bean
	 * @return
	 */
	protected int doUpdate(T bean) {
		return service.update(bean);
	}

	/**
	 * 处理对外的保存请求，标准的模板方法
	 * <p>
	 *     模板方法：调用{@link #validate(EntityBean, boolean)} (PersistableEntity, boolean)} 和 {@link #doSave(EntityBean)} 方法
	 * </p>
	 *
	 * @param bean
	 */
	public void save(T bean) {
		validate(bean, false);
		long id = doSave(bean);
		LOG.info("Save bean done:id={},class={}", id, bean.getClass().getSimpleName());
		Assert.isTrue(id > 0, StatusCode.DAO_SAVE_FAIL);
	}

	/**
	 * 处理对外的更新请求，标准的模板方法
	 * @param bean
	 */
	public void update(T bean) {
		validate(bean, true);
		int ret = doUpdate(bean);
		LOG.info("Update bean done:ret={},id={},class={}", ret, bean.getClass().getSimpleName(), bean.getId());
		Assert.isTrue(ret > 0, StatusCode.DAO_UPDATE_FAIL);
	}

	/**
	 * 设置操作人
	 * @param bean
	 * @param update
	 */
	protected void setOperator(T bean, boolean update) {
		if(bean instanceof EditableEntity) {
			SessionUser<User> user = sessionManager.getCurrentUser();
			if (user != null) {
				if(update) {
					((EditableEntity) bean).setCreator(null);
				} else {
					((EditableEntity) bean).setCreator(user.getUsername());
				}
				((EditableEntity) bean).setEditor(user.getUsername());
			}
		}
	}

	/**
	 * 填充搜索引擎参数，默认实现，如果有特殊情况，请自行实现
	 */
	protected QueryBuilder<T> renderSearchEngine(ParametersBuilder parametersBuilder) {
		QueryBuilder<T> builder = QueryBuilder.custom(getBeanType());

		if (parametersBuilder == null) return builder;

		Map<String, Object> parameters = parametersBuilder.build();
		int invalid = 0;
		for(Map.Entry<String, Object> entry : parameters.entrySet()) {
			String name = entry.getKey();
			Object value = entry.getValue();
			boolean valid = false;

			int oper = 0;
			if(name.startsWith("__LIKE__")) {
				oper = 1;
				name = name.substring(8);
			} else if(name.startsWith("__<=__")) {
				oper = 2;
				name = name.substring(6);
			} else if(name.startsWith("__>=__")) {
				oper = 3;
				name = name.substring(6);
			} else if (name.startsWith("__>__")) {
				oper = 4;
				name = name.substring(5);
			} else if (name.startsWith("__<__")) {
				oper = 5;
				name = name.substring(5);
			} else if (name.startsWith("__!=__")) {
				oper = 6;
				name = name.substring(6);
			}

			if(value instanceof String) {
				if(StringUtils.isBlank((String) value)) value = null;
			}

			if(value != null && isColumnExists(name)) {
				valid = true;
				switch (oper) {
					case 1:
						builder.andLike(name, "%" + value + "%");
						break;
					case 2:
						builder.andLessThan(name, value, true);
						break;
					case 3:
						builder.andGreaterThan(name, value, true);
						break;
					case 4:
						builder.andGreaterThan(name, value);
						break;
					case 5:
						builder.andLessThan(name, value);
						break;
					case 6:
						builder.andNotEquivalent(name, value);
						break;
					default:
						builder.andEquivalent(name, value);
				}
			} else {
				++invalid;
				if(LOG.isDebugEnabled()) {
					LOG.warn("Search field is ignored: name={}, value={}", name, value);
				}
			}
			if(parametersBuilder.isChainedDepend()) {
				if(valid && invalid > 0) throw new ServiceException("该查询条件必须遵守最左填充原则");
			}
		}

		return builder;
	}

	/**
	 * 检测一个字段列是否存在
	 * @param name
	 * @return
	 */
	private boolean isColumnExists(String name) {
		AnnotationHolder holder = AnnotationHelper.getAnnotationHolder(name, getBeanType());
		return holder != null;
	}

    /**
     * 子类可以实现查询逻辑
     * @param builder
     * @return
     */
	protected List<T> doQuery(QueryBuilder<T> builder) {
        return service.query(builder.build());
    }

	/**
	 * 执行实体检查操作
	 * @param entity
	 */
	protected void validate(T entity, boolean update) {
		doCheck(entity, update);
		setOperator(entity, update);
	}

	/**
	 * 执行参数逻辑校验检查工作
	 * @param entity
	 */
	protected void doCheck(T entity, boolean update) {}

	/**
	 * 计算AI库中的实体ID
	 * @param bean
	 * @return
	 */
	public String beanId(T bean) {
		return bean.getClass().getSimpleName() + BEAN_ID_SEPARATOR + bean.getId();
	}

	/**
	 * 计算AI库中的实体ID
	 * @param id
	 * @return
	 */
	public String beanId(long id) {
		return getBeanType().getSimpleName() + BEAN_ID_SEPARATOR + id;
	}
}
