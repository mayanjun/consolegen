package ${packageName}.util;

import org.apache.commons.codec.binary.Base64;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 *
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
public class ImageUtils {

    private ImageUtils() {
    }

    /**
     * 图像裁切
     * @param bufferedImage Bsee64图像
     * @param startX 起点X作坐标
     * @param startY 起点Y作坐标
     * @param endX 终点X坐标
     * @param endY 终点Y坐标
     * @return
     */
    public static String cropImage(String bufferedImage, int startX, int startY, int endX, int endY) {
        BufferedImage bufferedImage1 = cropImage(base64ToImage(bufferedImage), startX,startY, endX, endY);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();//io流
        try {
            ImageIO.write(bufferedImage1, "jpg", baos);//写入流中
            byte[] bytes = baos.toByteArray();//转换成字节

            return Base64.encodeBase64String(bytes);
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * 图像裁切
     * @param bufferedImage
     * @param startX 起点X作坐标
     * @param startY 起点Y作坐标
     * @param endX 终点X坐标
     * @param endY 终点Y坐标
     * @return
     */
    public static BufferedImage cropImage(BufferedImage bufferedImage, int startX, int startY, int endX, int endY) {
        int width = bufferedImage.getWidth();
        int height = bufferedImage.getHeight();
        if (startX == -1) {
            startX = 0;
        }
        if (startY == -1) {
            startY = 0;
        }
        if (endX == -1) {
            endX = width - 1;
        }
        if (endY == -1) {
            endY = height - 1;
        }

        endX = endX >= width ? width: endX;
        endY = endY >= height ? height: endY;

        BufferedImage result = new BufferedImage(endX - startX, endY - startY, 4);
        for (int x = startX; x < endX; ++x) {
            for (int y = startY; y < endY; ++y) {
                int rgb = bufferedImage.getRGB(x, y);
                result.setRGB(x - startX, y - startY, rgb);
            }
        }
        return result;
    }


    /**
     * Base64图片转换为 {@link BufferedImage} 对象
     * @param base64String
     * @return
     */
    public static BufferedImage base64ToImage(String base64String) {
        if (Base64.isBase64(base64String)) {
            InputStream inputStream = new ByteArrayInputStream(Base64.decodeBase64(base64String));
            try {
                return ImageIO.read(inputStream);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return  null;
    }

}
