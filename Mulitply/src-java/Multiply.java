import java.util.Scanner;

public class Multiply {
    static int n;
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        n = scanner.nextInt();

        int x, y;
        float[] matrix1 = new float[64];
        for (int i = 0; i < n * n; i ++) {
            x = i / n;
            y = i % n;
            matrix1[x * 8 + y] = scanner.nextFloat();
        }

        float[] matrix2 = new float[64];
        for (int i = 0; i < n * n; i ++) {
            x = i / n;
            y = i % n;
            matrix2[y * 8 + x] = scanner.nextFloat();
        }


        long startTime = System.nanoTime();
        float[] product = multiply(matrix1, matrix2);
        long endTime = System.nanoTime();
        long duration = (endTime - startTime);
        
        System.out.println(duration);
        
        // printMatrix(product);

    }

    static float[] multiply(float[] matrix1, float[] matrix2) {
        int x, y;
        float[] product = new float[64];
        for (int i = 0; i < n * n; i++) {
            x = i / n;
            y = i % n;
            float sum = 0;
            for (int j = 0; j < n; j++) {
                sum += matrix1[x * 8 + j] * matrix2[y * 8 + j];
            }
            product[i] = sum;
        }
        return product;
    }

    static void printMatrix(float[] product) {
        for (int i = 0; i < n * n; i++) {
            if (i % n == 0) System.out.println();
            System.out.print(product[i] + " ");
        }
    }


}
