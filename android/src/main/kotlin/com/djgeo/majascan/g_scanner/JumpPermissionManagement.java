package com.djgeo.majascan.g_scanner;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;

import com.djgeo.majascan.BuildConfig;


/**
 * https://github.com/hkq325800/JumpPermissionManagement
 */

public class JumpPermissionManagement {

    private static final String TAG = JumpPermissionManagement.class.getSimpleName();
    /**
     * Build.MANUFACTURER
     */
    private static final String MANUFACTURER_HUAWEI = "Huawei";           //華為
    private static final String MANUFACTURER_MEIZU = "魅族";               //魅族
    private static final String MANUFACTURER_XIAOMI = "Xiaomi";           //小米
    private static final String MANUFACTURER_SONY = "Sony";               //索尼
    private static final String MANUFACTURER_OPPO = "OPPO";
    private static final String MANUFACTURER_LG = "LG";
    private static final String MANUFACTURER_VIVO = "vivo";
    private static final String MANUFACTURER_SAMSUNG = "samsung";         //三星
    private static final String MANUFACTURER_LETV = "Letv";               //樂視
    private static final String MANUFACTURER_ZTE = "ZTE";                 //中興
    private static final String MANUFACTURER_YULONG = "YuLong";           //酷派  
    private static final String MANUFACTURER_LENOVO = "LENOVO";           //聯想

    public static void GoToSetting(Context context) throws Exception{
        switch (Build.MANUFACTURER){
            case MANUFACTURER_HUAWEI:
                Huawei(context);
                break;
            case MANUFACTURER_MEIZU:
                Meizu(context);
                break;
            case MANUFACTURER_XIAOMI:
                Xiaomi(context);
                break;
            case MANUFACTURER_SONY:
                Sony(context);
                break;
            case MANUFACTURER_OPPO:
                OPPO(context);
                break;
            case MANUFACTURER_LG:
                LG(context);
                break;
            case MANUFACTURER_LETV:
                Letv(context);
                break;
            default:
                ApplicationInfo(context);
                Log.e(TAG, "目前暫不支持此系統 : " + Build.MANUFACTURER);
                break;
        }
    }

    public static void Huawei(Context context) {
        Intent intent = new Intent();
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("packageName", BuildConfig.APPLICATION_ID);
        ComponentName comp = new ComponentName("com.huawei.systemmanager", "com.huawei.permissionmanager.ui.MainActivity");
        intent.setComponent(comp);
        context.startActivity(intent);
    }

    public static void Meizu(Context context) {
        Intent intent = new Intent("com.meizu.safe.security.SHOW_APPSEC");
        intent.addCategory(Intent.CATEGORY_DEFAULT);
        intent.putExtra("packageName", BuildConfig.APPLICATION_ID);
        context.startActivity(intent);
    }

    public static void Xiaomi(Context context) {
        Intent intent = new Intent("miui.intent.action.APP_PERM_EDITOR");
        ComponentName componentName = new ComponentName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity");
        intent.setComponent(componentName);
        intent.putExtra("extra_pkgname", BuildConfig.APPLICATION_ID);
        context.startActivity(intent);
    }

    public static void Sony(Context context) {
        Intent intent = new Intent();
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("packageName", BuildConfig.APPLICATION_ID);
        ComponentName comp = new ComponentName("com.sonymobile.cta", "com.sonymobile.cta.SomcCTAMainActivity");
        intent.setComponent(comp);
        context.startActivity(intent);
    }

    public static void OPPO(Context context) {
        Intent intent = new Intent();
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("packageName", BuildConfig.APPLICATION_ID);
        ComponentName comp = new ComponentName("com.color.safecenter", "com.color.safecenter.permission.PermissionManagerActivity");
        intent.setComponent(comp);
        context.startActivity(intent);
    }

    public static void LG(Context activity) {
        Intent intent = new Intent("android.intent.action.MAIN");
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("packageName", BuildConfig.APPLICATION_ID);
        ComponentName comp = new ComponentName("com.android.settings", "com.android.settings.Settings$AccessLockSummaryActivity");
        intent.setComponent(comp);
        activity.startActivity(intent);
    }

    public static void Letv(Context context) {
        Intent intent = new Intent();
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("packageName", BuildConfig.APPLICATION_ID);
        ComponentName comp = new ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.PermissionAndApps");
        intent.setComponent(comp);
        context.startActivity(intent);
    }

    /**
     * 只能打开到自带安全软件
     */
    public static void _360(Activity context) {
        Intent intent = new Intent("android.intent.action.MAIN");
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("packageName", BuildConfig.APPLICATION_ID);
        ComponentName comp = new ComponentName("com.qihoo360.mobilesafe", "com.qihoo360.mobilesafe.ui.index.AppEnterActivity");
        intent.setComponent(comp);
        context.startActivity(intent);
    }

    /**
     * 应用信息界面
     */
    public static void ApplicationInfo(Context context){
        Intent localIntent = new Intent();
        localIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        localIntent.setAction("android.settings.APPLICATION_DETAILS_SETTINGS");
        localIntent.setData(Uri.fromParts("package", context.getPackageName(), null));
        context.startActivity(localIntent);
    }

    /**
     * 系统设置界面
     * @param activity
     */
    public static void SystemConfig(Context activity) {
        Intent intent = new Intent(Settings.ACTION_SETTINGS);
        activity.startActivity(intent);
    }

}
