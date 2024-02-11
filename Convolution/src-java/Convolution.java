import java.util.Scanner;

public class Convolution {
    static int n;
    static int x;
    static int y;

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        n = scanner.nextInt();
        
        float[] kernel = new float[25];
        for (int i = 0; i < n * n; i++) {
            kernel[i] = scanner.nextFloat();
        }

        x = scanner.nextInt();
        y = scanner.nextInt();
        
        float[] pixels = new float[1000000];
        for (int i = 0; i < x * y; i++) {
            pixels[i] = scanner.nextFloat();
        }

        convolution(kernel, pixels);
    }

    static float convolve(float[] kernel, float[] matrix) {
        float sum = 0;
        for (int i = 0; i < n * n; i++) {
            sum += kernel[i] * matrix[i];
        }
        return sum;
    }

    static void convolution(float[] kernel, float[] pixels) {
        System.out.println(x);
        System.out.println(y);
        float[] matrix = new float[n * n];
        for (int i = 0; i < x * y; i++) {
            int xMain = i / x;
            int yMain = i % x;
            int xPrime;
            int yPrime;

            int index;
            int counter = 0;
            for (int j = 0; j < n; j++) {
                for (int k = 0; k < n; k++) {
                    xPrime = xMain + j - n/2;
                    yPrime = yMain + k - n/2;

                    if (xPrime < 0) xPrime = 0;
                    if (xPrime >= x) xPrime = x - 1;
                    if (yPrime < 0) yPrime = 0;
                    if (yPrime >= y) yPrime = y - 1;

                    index = xPrime * x + yPrime;

                    matrix[counter] = pixels[index];
                    counter++;
                }
            }

            System.out.println((int) convolve(kernel, matrix));
        }
    }
}