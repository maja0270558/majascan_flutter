package com.djgeo.majascan.g_scanner;

import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;

import com.djgeo.majascan.R;

import static android.Manifest.permission.CAMERA;
import static com.djgeo.majascan.g_scanner.PermissionUtil.Permission_denied_forever;
import static com.djgeo.majascan.g_scanner.PermissionUtil.Permission_granted;
import static com.djgeo.majascan.g_scanner.QrCodeScannerActivity.REQUEST_CAMERA;

public class ScanFragment extends Fragment implements ScanInteractorImpl.ScanCallbackInterface {

    private String mWebTitle;//如果title不為空 => 顯示webView

    private FrameLayout mCapturePreview;
    private View mScannerBar;
    private CheckBox mFlashlightBtn;
    private TextView mTvTitle;
    private Toolbar mToolbar;
    private ImageView mBackBtn;

    private ScanInteractor scanInteractor;
    private AlertDialog mGoToWebviewDialog;


    public static ScanFragment newInstance(String title, boolean hasFlashLight, int toolBarColor, int titleColor) {

        Bundle args = new Bundle();
        args.putString(QrCodeScannerActivity.TITLE, title);
        args.putBoolean(QrCodeScannerActivity.FLASHLIGHT, hasFlashLight);

        if (toolBarColor != 0) {
            args.putInt(QrCodeScannerActivity.BAR_COLOR, toolBarColor);
        }

        if (titleColor != 0) {
            args.putInt(QrCodeScannerActivity.TITLE_COLOR, titleColor);
        }


        ScanFragment fragment = new ScanFragment();
        fragment.setArguments(args);
        return fragment;

    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_scan, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        scanInteractor = new ScanInteractorImpl(this);
        mCapturePreview = view.findViewById(R.id.capture_preview);
        mScannerBar = view.findViewById(R.id.scan_bar);
        mTvTitle = view.findViewById(R.id.tv_title);
        mToolbar = view.findViewById(R.id.actionbar);

        //閃光燈
        mFlashlightBtn = view.findViewById(R.id.toggle_flashlight);
        mFlashlightBtn.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    scanInteractor.openFlash();
                } else {
                    scanInteractor.closeFlash();
                }

            }
        });

        //關閉按鈕
        mBackBtn = view.findViewById(R.id.back_btn);
        mBackBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getActivity() != null) {
                    getActivity().finish();
                }
            }
        });

        handleBundleData();
    }

    private void handleBundleData() {
        Bundle args = getArguments();
        if (args != null) {
//            mWebTitle = args.getString(BUNDLE_WEBVIEW_TITLE, "");
            String title = args.getString(QrCodeScannerActivity.TITLE, getString(R.string.scanner_title));
            mTvTitle.setText(title);

            boolean hasFlashLight = args.getBoolean(QrCodeScannerActivity.FLASHLIGHT, true);
            mFlashlightBtn.setVisibility(hasFlashLight ? View.VISIBLE : View.GONE);

            mToolbar.setBackgroundColor(args.getInt(QrCodeScannerActivity.BAR_COLOR, android.R.color.transparent));

            int titleColor = args.getInt(QrCodeScannerActivity.TITLE_COLOR, 0);
            if (titleColor != 0) {
                Drawable drawable = getResources().getDrawable(R.drawable.left_arrow);
                drawable.setColorFilter(new PorterDuffColorFilter(titleColor, PorterDuff.Mode.MULTIPLY));
                mBackBtn.setImageDrawable(drawable);

                mTvTitle.setTextColor(titleColor);
            }

        }
    }

    private void requestPermission() {
        if (getActivity() != null) {
            ActivityCompat.requestPermissions(getActivity(), new String[]{CAMERA}, REQUEST_CAMERA);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[],
                                           int[] grantResults) {
        if (requestCode == REQUEST_CAMERA) {
            if (grantResults.length > 0) {
                boolean cameraAccepted = grantResults[0] == PackageManager.PERMISSION_GRANTED;
                if (cameraAccepted) {
                    startScan();
                }
//                    if (!cameraAccepted) {
//                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                            if (shouldShowRequestPermissionRationale(CAMERA)) {
//                                requestPermissions(new String[]{CAMERA}, REQUEST_CAMERA);
//                                return;
//                            }
//                        }
//                    }
            }
        }
    }

    private void showGoToSettingDialog() {
        if (getActivity() != null) {
            new AlertDialog.Builder(getActivity())
                    .setMessage(getString(R.string.camera_permission_tips))
                    .setPositiveButton(getString(R.string.dialog_btn_go), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            PermissionUtil.goToSettingPermission(getActivity());
                        }
                    })
                    .setNegativeButton(getString(R.string.dialog_btn_cancel), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int which) {
                            getActivity().finish();
                        }
                    })
                    .create()
                    .show();
        }

    }

    @Override
    public void onStart() {
        super.onStart();
        int permissionStatus = PermissionUtil.getPermissionStatus(getActivity(), CAMERA);
        switch (permissionStatus) {
            case Permission_granted:
                startScan();
                break;
            default:
                requestPermission();
                break;
            case Permission_denied_forever:
                showGoToSettingDialog();
                break;
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        scanInteractor.stopPreview();
        mScannerBar.clearAnimation();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        scanInteractor.stopPreview();
        if (mGoToWebviewDialog != null) {
            mGoToWebviewDialog.dismiss();
        }
    }

    private void startScan() {
        if (getActivity() == null) return;
        mCapturePreview.removeAllViews();
        scanInteractor.initScan(mCapturePreview);
        scanInteractor.startPreview();

        Animation animation = AnimationUtils.loadAnimation(getActivity(), R.anim.scan_anim);
        mScannerBar.startAnimation(animation);
        animation.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
                if (mScannerBar != null) {
                    mScannerBar.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onAnimationEnd(Animation animation) {
                if (mScannerBar != null) {
                    mScannerBar.setVisibility(View.GONE);
                }
            }

            @Override
            public void onAnimationRepeat(Animation animation) {
            }
        });

    }

    @Override
    public void receiveResult(final String result) {
        final QrCodeScannerActivity activity = (QrCodeScannerActivity) getActivity();
        if (activity == null) return;
        if (!TextUtils.isEmpty(mWebTitle)) {
            //a.方式
            if (mGoToWebviewDialog == null || !mGoToWebviewDialog.isShowing()) {
                AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
                builder.setTitle(R.string.go_to_webview)
                        .setPositiveButton(getString(R.string.dialog_btn_go), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialogInterface, int i) {
                                activity.goToWebviewFragment(result, mWebTitle);
                            }
                        })
                        .setNegativeButton(getString(R.string.dialog_btn_cancel), null);
                mGoToWebviewDialog = builder.create();
                mGoToWebviewDialog.show();
            }

        } else {
            //b.方式
            activity.receiveAndSetResult(result);
        }
    }
}
