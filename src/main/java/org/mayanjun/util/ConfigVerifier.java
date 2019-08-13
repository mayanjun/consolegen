package org.mayanjun.util;

import org.apache.commons.beanutils.BeanUtilsBean;
import org.apache.commons.beanutils.PropertyUtilsBean;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.core.Assert;
import org.mayanjun.core.ServiceException;
import org.mayanjun.core.Status;
import org.mayanjun.gen.Configurable;
import org.mayanjun.gen.ValidateConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.beans.PropertyDescriptor;
import java.lang.reflect.Field;

/**
 * @author mayanjun
 * @date 2019-07-25
 */
public class ConfigVerifier {

    private static final Logger LOG = LoggerFactory.getLogger(ConfigVerifier.class);

    private ConfigVerifier() {
    }

    public static void verify(ValidateConfig config) {
//        List<String> strings = new ArrayList<>();
        PropertyUtilsBean pub = BeanUtilsBean.getInstance().getPropertyUtils();
        PropertyDescriptor descriptors[] = pub.getPropertyDescriptors(config);
        for (PropertyDescriptor origDescriptor : descriptors) {
            final String name = origDescriptor.getName();
            if ("class".equals(name)) {
                continue; // No point in trying to set an object's class
            }

            try {
                Field field = config.getClass().getDeclaredField(name);
                Configurable configurable = field.getAnnotation(Configurable.class);
                if (configurable != null) {
//                    String row = String.format("%s|%s|%s|%s|%s",
//                            name, field.getType().getSimpleName(), (configurable.required() ? "Y" : "N"), configurable.defaultValue(),  configurable.comment());
//
//                    strings.add(row);

                    String defaultValue = configurable.defaultValue();
                    if (configurable.required() || StringUtils.isNotBlank(defaultValue)) {
                        if (pub.isReadable(config, name) && pub.isWriteable(config, name)) {
                            final Object value = pub.getSimpleProperty(config, name);
                            if (value instanceof String) {
                                Assert.notBlank((String) value, config.getClass().getSimpleName() + "." + name + "配置不能为空");
                            }
                        }
                    }
                }
            } catch (ServiceException e) {
                throw e;
            } catch (Exception e) {
                LOG.error("Verify config error:" + config.getClass().getName(), e);
                throw new ServiceException(Status.PARAM_ERROR, null, null, e);
            }
        }

//        System.out.println("#######################" + config.getClass().getSimpleName());
//        Collections.sort(strings);
//        for (String string : strings) {
//            System.out.println(string);
//        }
    }
}
