package com.djgeo.majascan.g_scanner

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import android.os.Build

import androidx.annotation.IntDef
import androidx.core.content.PermissionChecker

import android.preference.Preference
import android.preference.PreferenceManager
import android.util.Log


import java.lang.annotation.RetentionPolicy.SOURCE
import kotlin.annotation.Retention

class PermissionUtil {

    companion object {

        private val TAG : String = PermissionUtil::class.java.simpleName
        private const val CHECK_PERMISSION : String = "CHECK_PERMISSION"

        const val Permission_denied_forever = -1
        const val Permission_denied = 0
        const val Permission_granted = 1

        fun getPermissionStatus(activity: Activity, permission: String): Int {
            var status = Permission_granted
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (PermissionChecker.checkSelfPermission(activity, permission) == PermissionChecker.PERMISSION_GRANTED) {
                    status = Permission_granted
                } else if (activity.shouldShowRequestPermissionRationale(permission)) {
                    status = Permission_denied
                } else {
                    val sp = PreferenceManager.getDefaultSharedPreferences(activity)
                    if (sp.getInt(CHECK_PERMISSION, 0) == 1) {
                        status = Permission_denied_forever
                    } else {
                        status = Permission_denied
                        sp.edit().putInt(CHECK_PERMISSION, 1).apply()
                    }
                }
            }
            return status
        }

        //進入android setting permission
        fun goToSettingPermission(context: Context) {
            try {
                JumpPermissionManagement.goToSetting(context)
            } catch (e: Exception) {
                Log.e(TAG, e.message!!)
                JumpPermissionManagement.ApplicationInfo(context)
            }

        }
    }
}