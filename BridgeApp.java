import java.util.Scanner;

public class BridgeApp {

    // 1. Tell Java that this method is implemented in an external C file.
    // Think of this like "import native_save_file from native_lib.c"
    public native void saveFileNative(String standardInput);

    // 2. This blocks loads the compiled C library when the app starts.
    static {
        System.loadLibrary("native_lib");
    }

    public static void main(String[] args) {
        // 3. This is just like Python's `input("Enter file name: ")`
        Scanner scanner = new Scanner(System.in);
        System.out.print("Enter file name to save data: ");
        
        // This variable is TAINTED. It comes straight from the user.
        String userInput = scanner.nextLine(); 

        // 4. Pass the tainted input across the bridge into the C function.
        BridgeApp app = new BridgeApp();
        System.out.println("[Java] Passing input to C extension...");
        app.saveFileNative(userInput);
        
        scanner.close();
    }
}