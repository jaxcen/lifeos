import Foundation

/// CloudBase 配置
enum CloudBaseConfig {
    /// 环境 ID
    static let envId = "lifeos-d7g1p0d2i18d22393"

    /// API 基础 URL（上海地域）
    static let baseURL = "https://\(envId).api.tcloudbasegateway.com"

    /// Publishable Key（客户端匿名访问）
    static let publishableKey = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjlkMWRjMzFlLWI0ZDAtNDQ4Yi1hNzZmLWIwY2M2M2Q4MTQ5OCJ9.eyJpc3MiOiJodHRwczovL2xpZmVvcy1kN2cxcDBkMmkxOGQyMjM5My5hcC1zaGFuZ2hhaS50Y2ItYXBpLnRlbmNlbnRjbG91ZGFwaS5jb20iLCJzdWIiOiJhbm9uIiwiYXVkIjoibGlmZW9zLWQ3ZzFwMGQyaTE4ZDIyMzkzIiwiZXhwIjo0MDgzODgyMDYxLCJpYXQiOjE3ODAxOTg4NjEsIm5vbmNlIjoiY2VuT3pENy1UVWFNOUc4djUtd25OQSIsImF0X2hhc2giOiJjZW5PekQ3LVRVYU05Rzh2NS13bk5BIiwibmFtZSI6IkFub255bW91cyIsInNjb3BlIjoiYW5vbnltb3VzIiwicHJvamVjdF9pZCI6ImxpZmVvcy1kN2cxcDBkMmkxOGQyMjM5MyIsIm1ldGEiOnsicGxhdGZvcm0iOiJQdWJsaXNoYWJsZUtleSJ9LCJ1c2VyX3R5cGUiOiIiLCJjbGllbnRfdHlwZSI6ImNsaWVudF91c2VyIiwiaXNfc3lzdGVtX2FkbWluIjpmYWxzZX0.hH5Qf7KKq0oN-aHCwsO2qzQHNkB0yug_xkdwDnlKd_9ZaALkViEvFdJyAhCppiguIa1IwqOGzrNyaTT-GKz0IXoMmN7-Gbsp0hG_jUfzkCX_qJtzgb_byT2lqZt4LzwMzh-sVOTB0eaDhd9_zfUhTnroik3iC5mxRWU0MiwuNrr34I0tgXhQroQPMZBTsqA3ThKZdy62V_OKFriZAOtTTYomGyA718j0hyEh8R_89uxP7VYnNqqe5oeksPL1Z7BGxEil0CAuMf86HMSj4eyobHSo6hraSadk-0RFhXhrfOWPwn0BVA69dLxMRhheie4L_fOyDNIUjO8fm31h1v2W7Q"

    /// 认证 API 路径
    enum AuthAPI {
        static let sendVerification = "/auth/v1/verification"
        static let verifyCode = "/auth/v1/verification/verify"
        static let signIn = "/auth/v1/signin"
        static let signUp = "/auth/v1/signup"
        static let signOut = "/auth/v1/signout"
        static let refreshToken = "/auth/v1/token"
        static let userInfo = "/auth/v1/user"
    }
}
