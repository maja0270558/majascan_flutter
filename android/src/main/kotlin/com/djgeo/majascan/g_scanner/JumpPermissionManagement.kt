package com.djgeo.majascan.g_scanner

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log

import com.djgeo.majascan.BuildConfig


/**
 * https://github.com/hkq325800/JumpPermissionManagement
 */

class JumpPermissionManagement {

    companion object {
        private val TAG = JumpPermissionManagement::class.java.simpleName
        /**
         * Build.MANUFACTURER
         */
        private val MANUFACTURER_HUAWEI = "Huawei"           //華為
        private val MANUFACTURER_MEIZU = "魅族"               //魅族
        private val MANUFACTURER_XIAOMI = "Xiaomi"           //小米
        private val MANUFACTURER_SONY = "Sony"               //索尼
        private val MANUFACTURER_OPPO = "OPPO"
        private val MANUFACTURER_LG = "LG"
        private val MANUFACTURER_VIVO = "vivo"
        private val MANUFACTURER_SAMSUNG = "samsung"         //三星
        private val MANUFACTURER_LETV = "Letv"               //樂視
        private val MANUFACTURER_ZTE = "ZTE"                 //中興
        private val MANUFACTURER_YULONG = "YuLong"           //酷派  
        private val MANUFACTURER_LENOVO = "LENOVO"           //聯想

        @Throws(Exception::class)
        fun goToSetting(context: Context) {
            when (Build.MANUFACTURER) {
                MANUFACTURER_HUAWEI -> Huawei(context)
                MANUFACTURER_MEIZU -> Meizu(context)
                MANUFACTURER_XIAOMI -> Xiaomi(context)
                MANUFACTURER_SONY -> Sony(context)
                MANUFACTURER_OPPO -> OPPO(context)
                MANUFACTURER_LG -> LG(context)
                MANUFACTURER_LETV -> Letv(context)
                else -> {
                    ApplicationInfo(context)
                    Log.e(TAG, "目前暫不支持此系統 : " + Build.MANUFACTURER)
                }
            }
        }


        fun Huawei(context: Context) {
            val intent = Intent()
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            intent.putExtra("packageName", BuildConfig.LIBRARY_PACKAGE_NAME)
            val comp = ComponentName("com.huawei.systemmanager", "com.huawei.permissionmanager.ui.MainActivity")
            intent.component = comp
            context.startActivity(intent)
        }

        fun Meizu(context: Context) {
            val intent = Intent("com.meizu.safe.security.SHOW_APPSEC")
            intent.addCategory(Intent.CATEGORY_DEFAULT)
            intent.putExtra("packageName", BuildConfig.LIBRARY_PACKAGE_NAME)
            context.startActivity(intent)
        }

        fun Xiaomi(context: Context) {
            val intent = Intent("miui.intent.action.APP_PERM_EDITOR")
            val componentName = ComponentName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity")
            intent.component = componentName
            intent.putExtra("extra_pkgname", BuildConfig.LIBRARY_PACKAGE_NAME)
            context.startActivity(intent)
        }

        fun Sony(context: Context) {
            val intent = Intent()
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            intent.putExtra("packageName", BuildConfig.LIBRARY_PACKAGE_NAME)
            val comp = ComponentName("com.sonymobile.cta", "com.sonymobile.cta.SomcCTAMainActivity")
            intent.component = comp
            context.startActivity(intent)
        }

        fun OPPO(context: Context) {
            val intent = Intent()
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            intent.putExtra("packageName", BuildConfig.LIBRARY_PACKAGE_NAME)
            val comp = ComponentName("com.color.safecenter", "com.color.safecenter.permission.PermissionManagerActivity")
            intent.component = comp
            context.startActivity(intent)
        }

        fun LG(activity: Context) {
            val intent = Intent("android.intent.action.MAIN")
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            intent.putExtra("packageName", BuildConfig.LIBRARY_PACKAGE_NAME)
            val comp = ComponentName("com.android.settings", "com.android.settings.Settings\$AccessLockSummaryActivity")
            intent.component = comp
            activity.startActivity(intent)
        }

        fun Letv(context: Context) {
            val intent = Intent()
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            intent.putExtra("packageName", BuildConfig.LIBRARY_PACKAGE_NAME)
            val comp = ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.PermissionAndApps")
            intent.component = comp
            context.startActivity(intent)
        }

        /**
         * 只能打开到自带安全软件
         */
        fun _360(context: Activity) {
            val intent = Intent("android.intent.action.MAIN")
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            intent.putExtra("packageName", BuildConfig.LIBRARY_PACKAGE_NAME)
            val comp = ComponentName("com.qihoo360.mobilesafe", "com.qihoo360.mobilesafe.ui.index.AppEnterActivity")
            intent.component = comp
            context.startActivity(intent)
        }

        /**
         * 应用信息界面
         */
        fun ApplicationInfo(context: Context) {
            val localIntent = Intent()
            localIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            localIntent.action = "android.settings.APPLICATION_DETAILS_SETTINGS"
            localIntent.data = Uri.fromParts("package", context.packageName, null)
            context.startActivity(localIntent)
        }

        /**
         * 系统设置界面
         * @param activity
         */
        fun SystemConfig(activity: Context) {
            val intent = Intent(Settings.ACTION_SETTINGS)
            activity.startActivity(intent)
        }
    }

}
