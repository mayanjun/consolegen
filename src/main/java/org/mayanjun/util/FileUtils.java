package org.mayanjun.util;

import java.io.File;

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class FileUtils {

    private FileUtils() {
    }

    public static boolean mkdirs (File file) {
        if (! file.exists()) return file.mkdirs();
        return true;
    }

    public static String getRootPath() {
        return FileUtils.class.getProtectionDomain().getCodeSource().getLocation().getPath();
    }
}
