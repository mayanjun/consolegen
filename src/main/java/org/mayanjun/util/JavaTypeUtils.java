package org.mayanjun.util;

import org.apache.commons.lang3.StringUtils;
import org.mayanjun.core.Assert;
import org.mayanjun.core.ServiceException;
import org.mayanjun.gen.FieldConfig;
import org.mayanjun.myjack.api.enums.DataType;

import java.util.HashMap;
import java.util.Map;

/**
 * @author mayanjun
 * @date 2019-07-18
 */
public class JavaTypeUtils {

    private JavaTypeUtils() {
    }

    private static final Map<String, String> PRIMITIVE_TYPES = new HashMap<String, String>(){{
        put("int", "Integer");
        put("short", "Short");
        put("byte", "Byte");
        put("long", "Long");
        put("char", "Character");
        put("float", "Float");
        put("double", "Double");
        put("boolean", "Boolean");
    }};

    private static final Map<String, DataType> DATABASE_JAVA_TYPE_MAPPING = new HashMap<String, DataType>(){{
        put("int", DataType.INT);
        put("short", DataType.MEDIUMINT);
        put("byte", DataType.TINYINT);
        put("long", DataType.BIGINT);
        put("char", DataType.CHAR);
        put("float", DataType.FLOAT);
        put("double", DataType.DOUBLE);
        put("boolean", DataType.BIT);
        put("Integer", DataType.INT);
        put("Short", DataType.MEDIUMINT);
        put("Byte", DataType.TINYINT);
        put("Long", DataType.BIGINT);
        put("Character", DataType.CHAR);
        put("Float", DataType.FLOAT);
        put("Double", DataType.DOUBLE);
        put("Boolean", DataType.BIT);
    }};

    public static DataType toDatabaseType(String primitiveJavaType) {
        return DATABASE_JAVA_TYPE_MAPPING.get(primitiveJavaType);
    }

    public static boolean isInteger(String javaType) {
        return "int".equals(javaType)
                || "long".equals(javaType)
                || "short".equals(javaType)
                || "byte".equals(javaType)
                || "Integer".equals(javaType)
                || "Long".equals(javaType)
                || "Short".equals(javaType)
                || "Byte".equals(javaType);
    }

    public static boolean isLong(String javaType) {
        return "long".equals(javaType)
                || "Long".equals(javaType);
    }

    public static boolean isFloat(String javaType) {
        return "double".equals(javaType)
                || "float".equals(javaType)
                || "Double".equals(javaType)
                || "Float".equals(javaType);
    }

    public static boolean isDate(String javaType) {
        return "Date".equals(javaType) || "java.util.Date".equals(javaType);
    }

    public static boolean isEnmuType(FieldConfig f) {
        return (f.getEnumValues() != null && f.getEnumValues().length > 0);
    }

    public static boolean isBoolean(String javaType) {
        return "boolean".equals(javaType.toLowerCase());
    }

    public static boolean isInt(String javaType) {
        return "int".equals(javaType) || "Integer".equals(javaType);
    }

    public static boolean isString(String javaType) {
        return "String".equals(javaType) || "java.lang.String".equals(javaType);
    }

    public static int nonPrimitiveTypeDatabaseLength(String javaType, String userLength) {
        if (isString(javaType)) {
            try {
                return Integer.parseInt(userLength);
            } catch (Exception e) {
                throw new ServiceException("Incorrect length value for String type: " + javaType + ">" + userLength);
            }
        }
        return 32;
    }

    public static String primitiveTypeDatabaseLength(String javaType, String userLength) {
        String ljt = javaType.toLowerCase();
        if ("float".equals(ljt) || "double".equals(ljt)) {
            if (StringUtils.isBlank(userLength)) {
                return "";
            } else {
                String ss[] = userLength.split(",");
                if (ss.length != 2) return "";
                try {
                    int a = Integer.parseInt(ss[0]);
                    int b = Integer.parseInt(ss[1]);
                    Assert.isTrue(a > b, "");
                } catch (Exception e) {
                    throw new ServiceException("Incorrect length value for Float type: " + javaType + ">" + userLength);
                }
                return userLength;
            }
        } else if ("boolean".equals(ljt)) {
            return "1";
        } else {
            return "";
        }
    }

    public static boolean isPrimitiveType(String javaType) {
        return PRIMITIVE_TYPES.containsKey(javaType) || PRIMITIVE_TYPES.containsValue(javaType);
    }

    public static String toPrimitiveWrapper(String javaType) {
        if (PRIMITIVE_TYPES.containsValue(javaType)) return javaType;
        String wrapper = PRIMITIVE_TYPES.get(javaType.toLowerCase());
        if (wrapper == null) throw new NullPointerException("Can't convert to the wrapper type:" + javaType);
        return wrapper;
    }
}
