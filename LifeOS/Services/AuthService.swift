import Foundation
import SwiftUI

/// 认证状态
enum AuthState: Equatable {
    case notAuthenticated
    case codeSent(verificationId: String)
    case authenticated(userId: String)
}

/// 用户认证信息
struct AuthUserInfo: Codable {
    let id: String
    let phone: String?
    let email: String?
    let username: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case phone
        case email
        case username
        case createdAt = "created_at"
    }
}

/// 登录响应
struct SignInResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int?
    let user: AuthUserInfo?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case user
    }
}

/// 发送验证码响应
struct SendVerificationResponse: Codable {
    let verificationId: String
    let expiresIn: Int?

    enum CodingKeys: String, CodingKey {
        case verificationId = "verification_id"
        case expiresIn = "expires_in"
    }
}

/// 验证码确认响应
struct VerifyCodeResponse: Codable {
    let verificationToken: String

    enum CodingKeys: String, CodingKey {
        case verificationToken = "verification_token"
    }
}

/// Token 存储 Key
private enum AuthStorageKey {
    static let accessToken = "cloudbase_access_token"
    static let refreshToken = "cloudbase_refresh_token"
    static let userId = "cloudbase_user_id"
    static let userPhone = "cloudbase_user_phone"
    static let userEmail = "cloudbase_user_email"
}

/// 认证服务 - 管理用户登录状态
@Observable
final class AuthService {
    /// 当前认证状态
    private(set) var authState: AuthState = .notAuthenticated

    /// 是否已登录
    var isAuthenticated: Bool {
        if case .authenticated = authState {
            return true
        }
        return false
    }

    /// 当前用户 ID
    var currentUserId: String? {
        if case .authenticated(let userId) = authState {
            return userId
        }
        return nil
    }

    /// 当前 Access Token
    private(set) var accessToken: String?

    /// 加载状态
    private(set) var isLoading = false

    /// 错误消息
    var errorMessage: String?

    /// 成功消息
    var successMessage: String?

    private let httpClient = CloudBaseHTTPClient.shared
    private let defaults = UserDefaults.standard

    init() {
        loadStoredAuth()
    }

    // MARK: - 加载已存储的认证信息

    private func loadStoredAuth() {
        if let token = defaults.string(forKey: AuthStorageKey.accessToken),
           let userId = defaults.string(forKey: AuthStorageKey.userId) {
            self.accessToken = token
            self.authState = .authenticated(userId: userId)
        }
    }

    // MARK: - 发送验证码

    /// 发送短信验证码
    /// - Parameter phoneNumber: 手机号（纯数字，如 "13800138000"）
    func sendVerificationCode(phoneNumber: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            successMessage = nil
        }

        // 格式化手机号：添加国际区号
        let formattedPhone = "+86 \(phoneNumber)"

        let body: [String: Any] = [
            "phone_number": formattedPhone,
            "target": "ANY"
        ]

        do {
            let response = try await httpClient.sendRaw(
                to: CloudBaseConfig.AuthAPI.sendVerification,
                body: body
            )

            guard let verificationId = response["verification_id"] as? String else {
                throw CloudBaseError.invalidResponse
            }

            await MainActor.run {
                self.authState = .codeSent(verificationId: verificationId)
                self.isLoading = false
                self.successMessage = "验证码已发送"
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "发送验证码失败: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - 验证验证码并登录

    /// 验证验证码并完成登录
    /// - Parameters:
    ///   - code: 验证码
    ///   - phoneNumber: 手机号
    func verifyCodeAndSignIn(code: String, phoneNumber: String) async {
        guard case .codeSent(let verificationId) = authState else {
            await MainActor.run {
                self.errorMessage = "请先发送验证码"
            }
            return
        }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        // Step 1: 验证验证码，获取 verification_token
        let verifyBody: [String: Any] = [
            "verification_id": verificationId,
            "verification_code": code
        ]

        do {
            let verifyResponse = try await httpClient.sendRaw(
                to: CloudBaseConfig.AuthAPI.verifyCode,
                body: verifyBody
            )

            guard let verificationToken = verifyResponse["verification_token"] as? String else {
                throw CloudBaseError.invalidResponse
            }

            // Step 2: 使用 verification_token 登录
            let signInBody: [String: Any] = [
                "verification_token": verificationToken
            ]

            let signInResponse = try await httpClient.sendRaw(
                to: CloudBaseConfig.AuthAPI.signIn,
                body: signInBody
            )

            guard let accessToken = signInResponse["access_token"] as? String,
                  let refreshToken = signInResponse["refresh_token"] as? String else {
                throw CloudBaseError.invalidResponse
            }

            // 获取用户信息
            let userId = (signInResponse["user"] as? [String: Any])?["id"] as? String ?? "unknown"

            // 保存认证信息
            saveAuth(
                accessToken: accessToken,
                refreshToken: refreshToken,
                userId: userId,
                phone: phoneNumber
            )

            await MainActor.run {
                self.accessToken = accessToken
                self.authState = .authenticated(userId: userId)
                self.isLoading = false
                self.successMessage = "登录成功"
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "登录失败: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - 发送邮箱验证码

    /// 发送邮箱验证码
    /// - Parameter email: 邮箱地址
    func sendEmailVerificationCode(email: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            successMessage = nil
        }

        let body: [String: Any] = [
            "email": email,
            "target": "ANY"
        ]

        do {
            let response = try await httpClient.sendRaw(
                to: CloudBaseConfig.AuthAPI.sendVerification,
                body: body
            )

            guard let verificationId = response["verification_id"] as? String else {
                throw CloudBaseError.invalidResponse
            }

            await MainActor.run {
                self.authState = .codeSent(verificationId: verificationId)
                self.isLoading = false
                self.successMessage = "验证码已发送到邮箱"
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "发送验证码失败: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - 验证邮箱验证码并注册/登录

    /// 验证邮箱验证码并完成注册/登录
    /// - Parameters:
    ///   - code: 验证码
    ///   - email: 邮箱地址
    ///   - password: 密码（可选，用于设置账号密码）
    func verifyEmailCodeAndSignIn(code: String, email: String, password: String? = nil) async {
        guard case .codeSent(let verificationId) = authState else {
            await MainActor.run {
                self.errorMessage = "请先发送验证码"
            }
            return
        }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        // Step 1: 验证验证码，获取 verification_token
        let verifyBody: [String: Any] = [
            "verification_id": verificationId,
            "verification_code": code
        ]

        do {
            let verifyResponse = try await httpClient.sendRaw(
                to: CloudBaseConfig.AuthAPI.verifyCode,
                body: verifyBody
            )

            guard let verificationToken = verifyResponse["verification_token"] as? String else {
                throw CloudBaseError.invalidResponse
            }

            // Step 2: 使用 verification_token 注册/登录
            var signUpBody: [String: Any] = [
                "email": email,
                "verification_token": verificationToken
            ]

            // 如果提供了密码，设置密码
            if let password = password {
                signUpBody["password"] = password
            }

            let signInResponse = try await httpClient.sendRaw(
                to: CloudBaseConfig.AuthAPI.signUp,
                body: signUpBody
            )

            guard let accessToken = signInResponse["access_token"] as? String,
                  let refreshToken = signInResponse["refresh_token"] as? String else {
                throw CloudBaseError.invalidResponse
            }

            // 获取用户信息
            let userId = (signInResponse["user"] as? [String: Any])?["id"] as? String ?? "unknown"

            // 保存认证信息
            saveAuth(
                accessToken: accessToken,
                refreshToken: refreshToken,
                userId: userId,
                email: email
            )

            await MainActor.run {
                self.accessToken = accessToken
                self.authState = .authenticated(userId: userId)
                self.isLoading = false
                self.successMessage = "登录成功"
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "登录失败: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - 退出登录

    func signOut() async {
        await MainActor.run {
            isLoading = true
        }

        // 尝试调用退出登录 API（可选，即使失败也继续清除本地状态）
        if let token = accessToken {
            _ = try? await httpClient.sendRaw(
                to: CloudBaseConfig.AuthAPI.signOut,
                token: token
            )
        }

        clearStoredAuth()

        await MainActor.run {
            self.accessToken = nil
            self.authState = .notAuthenticated
            self.isLoading = false
            self.successMessage = "已退出登录"
        }
    }

    // MARK: - 存储管理

    private func saveAuth(accessToken: String, refreshToken: String, userId: String, phone: String? = nil, email: String? = nil) {
        defaults.set(accessToken, forKey: AuthStorageKey.accessToken)
        defaults.set(refreshToken, forKey: AuthStorageKey.refreshToken)
        defaults.set(userId, forKey: AuthStorageKey.userId)
        if let phone = phone {
            defaults.set(phone, forKey: AuthStorageKey.userPhone)
        }
        if let email = email {
            defaults.set(email, forKey: AuthStorageKey.userEmail)
        }
    }

    private func clearStoredAuth() {
        defaults.removeObject(forKey: AuthStorageKey.accessToken)
        defaults.removeObject(forKey: AuthStorageKey.refreshToken)
        defaults.removeObject(forKey: AuthStorageKey.userId)
        defaults.removeObject(forKey: AuthStorageKey.userPhone)
        defaults.removeObject(forKey: AuthStorageKey.userEmail)
    }

    /// 获取存储的手机号
    var storedPhone: String? {
        defaults.string(forKey: AuthStorageKey.userPhone)
    }

    /// 获取存储的邮箱
    var storedEmail: String? {
        defaults.string(forKey: AuthStorageKey.userEmail)
    }

    // MARK: - 刷新 Token

    func refreshAccessToken() async throws {
        guard let refreshToken = defaults.string(forKey: AuthStorageKey.refreshToken) else {
            throw CloudBaseError.invalidResponse
        }

        let body: [String: Any] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]

        let response = try await httpClient.sendRaw(
            to: CloudBaseConfig.AuthAPI.refreshToken,
            body: body
        )

        guard let newAccessToken = response["access_token"] as? String,
              let newRefreshToken = response["refresh_token"] as? String else {
            throw CloudBaseError.invalidResponse
        }

        self.accessToken = newAccessToken
        defaults.set(newAccessToken, forKey: AuthStorageKey.accessToken)
        defaults.set(newRefreshToken, forKey: AuthStorageKey.refreshToken)
    }
}
