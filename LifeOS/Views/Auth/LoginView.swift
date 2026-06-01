import SwiftUI
import Combine

/// 登录页面 - 手机号短信验证码登录
struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authService = AuthService()

    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var codeSent = false
    @State private var countdown = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo 和标题
                headerSection

                // 登录表单
                formSection

                // 提示信息
                if let error = authService.errorMessage {
                    errorText(error)
                }

                if let success = authService.successMessage {
                    successText(success)
                }

                Spacer()

                // 底部协议
                agreementSection
            }
            .padding(.horizontal, 24)
            .background(Color.lifeBackground)
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(timer) { _ in
                if countdown > 0 {
                    countdown -= 1
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - 头部

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.lifeAccent)

            Text("登录 LifeOS")
                .font(.title2)
                .fontWeight(.bold)

            Text("使用手机号登录，数据安全同步")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - 表单

    private var formSection: some View {
        VStack(spacing: 20) {
            // 手机号输入
            HStack {
                Image(systemName: "phone")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)

                TextField("请输入手机号", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .disabled(codeSent)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // 验证码输入（发送后显示）
            if codeSent {
                HStack {
                    Image(systemName: "lock")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)

                    TextField("请输入验证码", text: $verificationCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // 发送验证码 / 登录按钮
            if !codeSent {
                Button {
                    Task {
                        await authService.sendVerificationCode(phoneNumber: phoneNumber)
                        if authService.successMessage != nil {
                            codeSent = true
                            startCountdown()
                        }
                    }
                } label: {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("获取验证码")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(phoneNumber.count >= 11 ? Color.lifeAccent : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(phoneNumber.count < 11 || authService.isLoading)
            } else {
                Button {
                    Task {
                        await authService.verifyCodeAndSignIn(
                            code: verificationCode,
                            phoneNumber: phoneNumber
                        )
                        if authService.isAuthenticated {
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("登录")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(verificationCode.count >= 4 ? Color.lifeAccent : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(verificationCode.count < 4 || authService.isLoading)

                // 重新发送按钮
                Button {
                    Task {
                        codeSent = false
                        verificationCode = ""
                        await authService.sendVerificationCode(phoneNumber: phoneNumber)
                        if authService.successMessage != nil {
                            codeSent = true
                            startCountdown()
                        }
                    }
                } label: {
                    Text(countdown > 0 ? "重新发送 (\(countdown)s)" : "重新发送验证码")
                        .font(.subheadline)
                        .foregroundStyle(countdown > 0 ? .secondary : Color.lifeAccent)
                }
                .disabled(countdown > 0 || authService.isLoading)
            }
        }
    }

    // MARK: - 提示文本

    private func errorText(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func successText(_ message: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.green)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - 协议

    private var agreementSection: some View {
        VStack(spacing: 8) {
            Text("登录即表示同意")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Button("《用户协议》") {
                    // TODO: 显示用户协议
                }
                .font(.caption)

                Text("和")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("《隐私政策》") {
                    // TODO: 显示隐私政策
                }
                .font(.caption)
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - 倒计时

    private func startCountdown() {
        countdown = 60
    }
}

#Preview {
    LoginView()
}
