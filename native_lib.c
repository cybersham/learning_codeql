#include <jni.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h> // Added for strerror
#include <errno.h>  // Added to get the error number

JNIEXPORT void JNICALL Java_BridgeApp_saveFileNative(JNIEnv *env, jobject obj, jstring standardInput) {
    
    const char *filename = (*env)->GetStringUTFChars(env, standardInput, NULL);
    if (filename == NULL) {
        return; 
    }

    printf("[C Extension] Received filename: %s\n", filename);

    // THE SINK
    FILE *file = fopen(filename, "w");
    
    if (file != NULL) {
        fprintf(file, "Confidential Data Transformed by C Extension!\n");
        fclose(file);
        printf("[C Extension] File written successfully!\n");
    } else {
        // This will print the exact reason from macOS (e.g., Permission Denied)
        printf("[C Extension] Failed to open/create file. Reason: %s\n", strerror(errno));
    }

    (*env)->ReleaseStringUTFChars(env, standardInput, filename);
}