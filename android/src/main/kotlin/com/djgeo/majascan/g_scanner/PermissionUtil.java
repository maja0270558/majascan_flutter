package com.djgeo.majascan.g_scanner;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.util.Log;

import androidx.annotation.IntDef;
import androidx.annotation.NonNull;
import androidx.core.content.PermissionChecker;

import java.lang.annotation.Retention;

import static java.lang.annotation.RetentionPolicy.SOURCE;

public class PermissionUtil {

    private static final String TAG = PermissionUtil.class.getSimpleName();

    @Retention(SOURCE)
    @IntDef({Permission_granted, Permission_denied, Permission_denied_forever})
    public @interface Status {
    }

    public static final int Permission_denied_forever = -1;
    public static final int Permission_denied = 0;
    public static final int Permission_granted = 1;

    public static @Status int getPermissionStatus(Activity activity, @NonNull String permission) {
        int status = Permission_granted;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {

            if (PermissionChecker.checkSelfPermission(activity, permission) == PermissionChecker.PERMISSION_GRANTED) {
                status = Permission_granted;
            } else if (activity.shouldShowRequestPermissionRationale(permission)) {
                status = Permission_denied;
            } else {
                status = Permission_denied_forever;
            }
        }
        return status;
    }

    //進入android setting permission
    public static void goToSettingPermission(Context context) {
        try {
            JumpPermissionManagement.GoToSetting(context);
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
            JumpPermissionManagement.ApplicationInfo(context);
        }
    }
}
