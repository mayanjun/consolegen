package org.mayanjun.util;

/**
 * @author mayanjun
 * @date 2019-07-18
 */
public class Strings {

    private Strings() {
    }

    public static String hump2Underline(String src, String prefix) {
        return convertHump(src, prefix, '_', false);
    }

    public static String convertHump(String src, String prefix, char delimiter, boolean deleteFirstDelimiter) {
        if (src == null) src = "";
        StringBuffer sb = new StringBuffer();
        char cs[] = src.toCharArray();
        for (char c : cs) {
            if (Character.isUpperCase(c)) {
                sb.append(delimiter);
                sb.append(Character.toLowerCase(c));
            } else {
                sb.append(c);
            }
        }

        if (prefix != null) {
            if (sb.length() == 0 || sb.charAt(0) != delimiter) sb.insert(0, prefix + delimiter);
            else sb.insert(0, prefix);
        }

        if (deleteFirstDelimiter) {
            if (sb.charAt(0) == delimiter) sb.deleteCharAt(0);
        }

        return sb.toString();
    }

    public static String toHump(String src, String prefix) {
       StringBuffer sb = new StringBuffer(src);
       sb.setCharAt(0, Character.toUpperCase(sb.charAt(0)));
       sb.insert(0, prefix);
       return sb.toString();
    }

    public static String toClassName(String javaType) {
        StringBuffer sb = new StringBuffer(javaType);
        if (Character.isLowerCase(sb.charAt(0))) {
            sb.setCharAt(0, Character.toUpperCase(sb.charAt(0)));
        }
        return sb.toString();
    }

    /**
     * 根据实体的类型生成 Spring MVC RequestMapping 的路径映射名
     * @param entityClassName
     * @return
     */
    public static String toRequestMapping(String entityClassName) {
        return Strings.convertHump(entityClassName, null, '-', true);
    }

    public static String generateSecretKey(int len) {
        // 33 - 126
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < len; i++) {
            int cp = (int) (Math.random() * 94);
            char c = (char) (cp + 33);
            if (c == '\\') {
                sb.append("\\\\");
            } else if (c == '"') {
                sb.append("\\\"");
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }
}
