package com.djgeo.majascan.g_scanner

import android.view.ViewGroup

interface ScanInteractor {

    fun initScan(previewContainer: ViewGroup)

    fun startPreview()

    fun stopPreview()

    fun openFlash()

    fun closeFlash()

}