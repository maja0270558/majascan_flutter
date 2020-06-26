package com.djgeo.majascan.g_scanner


import android.Manifest.permission.CAMERA
import android.app.Activity
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.PorterDuff
import android.graphics.PorterDuffColorFilter
import android.os.Bundle
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.widget.Toolbar
import androidx.core.app.ActivityCompat
import androidx.fragment.app.Fragment
import com.djgeo.majascan.R
import com.djgeo.majascan.g_scanner.QrCodeScannerActivity.Companion.REQUEST_CAMERA
import android.graphics.drawable.GradientDrawable
import android.widget.*
import androidx.core.content.ContextCompat
import kotlin.math.min


class ScanFragment : Fragment(), ScanInteractorImpl.ScanCallbackInterface {

    private val mWebTitle: String? = null

    private var mCapturePreview: FrameLayout? = null
    private var mScannerBar: View? = null
    private var mFlashlightBtn: CheckBox? = null
    private var mTvTitle: TextView? = null
    private var mToolbar: Toolbar? = null
    private var mBackBtn: ImageView? = null
    private var mQrView: QrBorderView? = null
    private var mScanBar: View? = null

    private var scanInteractor: ScanInteractor? = null
    private var mGoToWebviewDialog: AlertDialog? = null

    companion object {

        fun newInstance(title: String, hasFlashLight: Boolean, toolBarColor: Int, titleColor: Int,
                        qrCornerColor: Int = 0, qrScanColor: Int = 0, scanAreaScale: Float): ScanFragment {

            val args = Bundle()
            args.putString(QrCodeScannerActivity.TITLE, title)
            args.putBoolean(QrCodeScannerActivity.FLASHLIGHT, hasFlashLight)

            if (toolBarColor != 0) {
                args.putInt(QrCodeScannerActivity.BAR_COLOR, toolBarColor)
            }

            if (titleColor != 0) {
                args.putInt(QrCodeScannerActivity.TITLE_COLOR, titleColor)
            }

            if (qrCornerColor != 0) {
                args.putInt(QrCodeScannerActivity.QR_CORNER_COLOR, qrCornerColor)
            }

            if (qrScanColor != 0) {
                args.putInt(QrCodeScannerActivity.QR_SCANNER_COLOR, qrScanColor)
            }

            args.putFloat(QrCodeScannerActivity.SCAN_AREA_SCALE, scanAreaScale)

            val fragment = ScanFragment()
            fragment.arguments = args
            return fragment

        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_scan, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        scanInteractor = ScanInteractorImpl(this)
        mCapturePreview = view.findViewById(R.id.capture_preview)
        mScannerBar = view.findViewById(R.id.scan_bar)
        mTvTitle = view.findViewById(R.id.tv_title)
        mToolbar = view.findViewById(R.id.actionbar)
        mQrView = view.findViewById(R.id.capture_crop_view)
        mScanBar = view.findViewById(R.id.scan_bar)

        //閃光燈
        mFlashlightBtn = view.findViewById(R.id.toggle_flashlight)
        mFlashlightBtn?.setOnCheckedChangeListener { _, isChecked ->
            if (isChecked) {
                scanInteractor?.openFlash()
            } else {
                scanInteractor?.closeFlash()
            }
        }

        //關閉按鈕
        mBackBtn = view.findViewById(R.id.back_btn)
        mBackBtn?.setOnClickListener { finishActivityWithoutResult() }

        handleBundleData()
    }

    private fun handleBundleData() {
        val args = arguments
        if (args != null && context != null) {
            val title = args.getString(QrCodeScannerActivity.TITLE, getString(R.string.scanner_title))
            mTvTitle?.text = title

            val hasFlashLight = args.getBoolean(QrCodeScannerActivity.FLASHLIGHT, true)
            mFlashlightBtn?.visibility = if (hasFlashLight) View.VISIBLE else View.GONE

            mToolbar?.setBackgroundColor(args.getInt(QrCodeScannerActivity.BAR_COLOR, android.R.color.transparent))

            val titleColor = args.getInt(QrCodeScannerActivity.TITLE_COLOR, 0)
            if (titleColor != 0) {
                val drawable = ContextCompat.getDrawable(context!!, R.drawable.left_arrow)
                drawable?.let {
                    it.colorFilter = PorterDuffColorFilter(titleColor, PorterDuff.Mode.MULTIPLY)
                    mBackBtn?.setImageDrawable(it)
                }
                mTvTitle?.setTextColor(titleColor)
            }

            val qRCornerColor = args.getInt(QrCodeScannerActivity.QR_CORNER_COLOR, 0)
            if (qRCornerColor != 0) {
                mQrView?.setQRCornerColor(qRCornerColor)
            }

            //gradient
            val qRScannerColor = args.getInt(QrCodeScannerActivity.QR_SCANNER_COLOR, Color.rgb(255, 136, 0))
            val gd = GradientDrawable(GradientDrawable.Orientation.LEFT_RIGHT,
                    intArrayOf(qRScannerColor, Color.WHITE, qRScannerColor))
            mScanBar?.background = gd

            //依據BundleData調整mQrView寬高
            var scale = args.getFloat(QrCodeScannerActivity.SCAN_AREA_SCALE)
            if (scale <= 0F) scale = 0F
            if (scale >= 1F) scale = 1F
            val length = (min(resources.displayMetrics.widthPixels,
                    resources.displayMetrics.heightPixels) * scale).toInt()
            val layoutParams = RelativeLayout.LayoutParams(length, length)
            layoutParams.addRule(RelativeLayout.CENTER_IN_PARENT)
            mQrView?.layoutParams = layoutParams
        }
    }

    private fun requestPermission() {
        activity?.let {
            ActivityCompat.requestPermissions(it, arrayOf(CAMERA), REQUEST_CAMERA)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>,
                                            grantResults: IntArray) {
        if (requestCode == REQUEST_CAMERA) {
            if (grantResults.isNotEmpty()) {
                val cameraAccepted = grantResults[0] == PackageManager.PERMISSION_GRANTED
                if (cameraAccepted) {
                    startScan()
                } else {
                    finishActivityWithoutResult()
                }
            }
        }
    }

    private fun showGoToSettingDialog() {
        activity?.let {
            AlertDialog.Builder(it)
                    .setMessage(getString(R.string.camera_permission_tips))
                    .setPositiveButton(getString(R.string.dialog_btn_go)) { _, _ -> activity?.let { PermissionUtil.goToSettingPermission(activity!!) } }
                    .setNegativeButton(getString(R.string.dialog_btn_cancel)) { _, _ -> finishActivityWithoutResult() }
                    .setCancelable(false)
                    .create()
                    .show()
        }
    }

    private fun finishActivityWithoutResult() {
        val activity = activity as QrCodeScannerActivity? ?: return
        activity?.receiveAndSetResult("")
    }

    override fun onStart() {
        super.onStart()
        when (PermissionUtil.getPermissionStatus(activity as Activity, CAMERA)) {
            PermissionUtil.Permission_granted -> startScan()
            PermissionUtil.Permission_denied -> requestPermission()
            PermissionUtil.Permission_denied_forever -> showGoToSettingDialog()
        }
    }

    override fun onStop() {
        super.onStop()
        scanInteractor?.stopPreview()
        mScannerBar?.clearAnimation()
    }

    override fun onDestroy() {
        super.onDestroy()
        scanInteractor?.stopPreview()
        mGoToWebviewDialog?.dismiss()
    }

    private fun startScan() {
        activity?.let {
            mCapturePreview?.removeAllViews()
            scanInteractor?.initScan(mCapturePreview!!)
            scanInteractor?.startPreview()

            val animation = AnimationUtils.loadAnimation(it, R.anim.scan_anim)
            mScannerBar?.startAnimation(animation)
            animation.setAnimationListener(object : Animation.AnimationListener {
                override fun onAnimationStart(animation: Animation) {
                    mScannerBar?.visibility = View.VISIBLE
                }

                override fun onAnimationEnd(animation: Animation) {
                    mScannerBar?.visibility = View.GONE
                }

                override fun onAnimationRepeat(animation: Animation) {}
            })
        }
    }

    override fun receiveResult(result: String) {
        val activity = activity as QrCodeScannerActivity? ?: return
        if (!TextUtils.isEmpty(mWebTitle)) {
            //a.方式
            if (mGoToWebviewDialog == null || !mGoToWebviewDialog!!.isShowing) {
                val builder = AlertDialog.Builder(getActivity()!!)
                builder.setTitle(R.string.go_to_webview)
                        .setPositiveButton(getString(R.string.dialog_btn_go)) { _, _ -> activity.goToWebviewFragment(result, mWebTitle!!) }
                        .setNegativeButton(getString(R.string.dialog_btn_cancel), null)
                mGoToWebviewDialog = builder.create()
                mGoToWebviewDialog!!.show()
            }

        } else {
            //b.方式
            activity.receiveAndSetResult(result)
        }
    }
}
