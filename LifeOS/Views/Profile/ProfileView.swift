import SwiftUI
import SwiftData

/// 我的页面
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var entries: [DailyEntry]
    @State private var showProfileSetup = false
    @State private var showGrowthTrajectory = false
    @State private var showLogin = false
    @State private var authService = AuthService()

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.spacingL) {
                    // 账号登录/状态
                    accountSection

                    // 画像引导
                    if profile == nil || !(profile?.isProfileComplete ?? false) {
                        profileSetupBanner
                    }

                    // 画像摘要
                    if let profile, profile.isProfileComplete {
                        profileSummaryCard(profile)
                    }

                    // 成长轨迹入口
                    growthTrajectoryButton

                    // 数据统计
                    statsSection

                    // 关于
                    aboutSection
                }
                .padding(Layout.spacingL)
            }
            .background(Color.lifeBackground)
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showProfileSetup) {
                ProfileSetupView(existingProfile: profile)
            }
            .navigationDestination(isPresented: $showGrowthTrajectory) {
                GrowthTrajectoryView()
            }
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
        }
    }

    // MARK: - 账号区域

    private var accountSection: some View {
        VStack(spacing: Layout.spacingM) {
            if authService.isAuthenticated {
                // 已登录状态
                HStack(spacing: Layout.spacingL) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.lifeAccent)

                    VStack(alignment: .leading, spacing: Layout.spacingXS) {
                        Text("已登录")
                            .font(.lifeBodyEmphasis)
                            .foregroundStyle(Color.lifeText)
                        Text(formatPhone(authService.storedPhone))
                            .font(.lifeCaption)
                            .foregroundStyle(Color.lifeTextSecondary)
                    }

                    Spacer()

                    Button("退出") {
                        Task {
                            await authService.signOut()
                        }
                    }
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
                }
                .padding(Layout.spacingL)
                .background(Color.lifeCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
                .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
            } else {
                // 未登录状态
                Button { showLogin = true } label: {
                    HStack(spacing: Layout.spacingL) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.lifeAccent)

                        VStack(alignment: .leading, spacing: Layout.spacingXS) {
                            Text("登录账号")
                                .font(.lifeBodyEmphasis)
                                .foregroundStyle(Color.lifeText)
                            Text("登录后数据可云端同步")
                                .font(.lifeCaption)
                                .foregroundStyle(Color.lifeTextSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.lifeTextSecondary)
                    }
                    .padding(Layout.spacingL)
                    .background(Color.lifeAccent.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
                }
            }
        }
    }

    /// 格式化手机号显示
    private func formatPhone(_ phone: String?) -> String {
        guard let phone = phone else { return "" }
        // 如果是 "+86 13800138000" 格式，只显示后四位
        if phone.hasPrefix("+86 ") {
            let number = String(phone.dropFirst(4))
            if number.count == 11 {
                return "****" + String(number.suffix(4))
            }
        }
        return phone
    }

    // MARK: - 画像引导

    private var profileSetupBanner: some View {
        Button { showProfileSetup = true } label: {
            HStack(spacing: Layout.spacingL) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.lifeAccent)

                VStack(alignment: .leading, spacing: Layout.spacingXS) {
                    Text("让 AI 更了解你")
                        .font(.lifeBodyEmphasis)
                        .foregroundStyle(Color.lifeText)
                    Text("花 1 分钟设置画像，获得更懂你的日记")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.lifeTextSecondary)
            }
            .padding(Layout.spacingL)
            .background(Color.lifeAccent.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
        }
    }

    // MARK: - 画像摘要

    private func profileSummaryCard(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            HStack {
                Text(profile.name)
                    .font(.lifeTitle)
                    .foregroundStyle(Color.lifeText)
                Spacer()
                Button("编辑") { showProfileSetup = true }
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeAccent)
            }

            if !profile.idealSelfDescription.isEmpty {
                VStack(alignment: .leading, spacing: Layout.spacingXS) {
                    Text("想成为")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)
                    Text(profile.idealSelfDescription)
                        .font(.lifeBody)
                        .foregroundStyle(Color.lifeText)
                }
            }

            if !profile.coreValues.isEmpty {
                HStack(spacing: Layout.spacingS) {
                    Text("价值观")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)
                    ForEach(profile.coreValues, id: \.self) { value in
                        Text(value)
                            .font(.lifeTag)
                            .foregroundStyle(Color.lifeAccent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.lifeAccent.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }

            if !profile.currentGoals.isEmpty {
                VStack(alignment: .leading, spacing: Layout.spacingXS) {
                    Text("当前目标")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)
                    ForEach(profile.currentGoals, id: \.self) { goal in
                        Text(goal)
                            .font(.lifeBody)
                            .foregroundStyle(Color.lifeText)
                    }
                }
            }
        }
        .lifeCard()
    }

    // MARK: - 成长轨迹

    private var growthTrajectoryButton: some View {
        Button { showGrowthTrajectory = true } label: {
            HStack(spacing: Layout.spacingM) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.lifeYi)
                    .frame(width: 40, height: 40)
                    .background(Color.lifeYi.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: Layout.spacingXS) {
                    Text("成长轨迹")
                        .font(.lifeBodyEmphasis)
                        .foregroundStyle(Color.lifeText)
                    Text("查看你朝理想自我前进的轨迹")
                        .font(.lifeCaption)
                        .foregroundStyle(Color.lifeTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.lifeTextSecondary)
            }
            .padding(Layout.spacingL)
            .background(Color.lifeCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
        }
    }

    // MARK: - 数据统计

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: Layout.spacingL) {
            Text("数据")
                .font(.lifeHeadline)
                .foregroundStyle(Color.lifeText)

            HStack(spacing: Layout.spacingL) {
                statItem(
                    icon: "pencil.line",
                    value: "\(entries.count)",
                    label: "总记录"
                )

                statItem(
                    icon: "calendar",
                    value: "\(uniqueDays)",
                    label: "记录天数"
                )
            }
        }
        .lifeCard()
    }

    private var uniqueDays: Int {
        let calendar = Calendar.current
        let days = Set(entries.map { calendar.startOfDay(for: $0.date) })
        return days.count
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: Layout.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.lifeAccent)

            Text(value)
                .font(.lifeTitle)
                .foregroundStyle(Color.lifeText)

            Text(label)
                .font(.lifeCaption)
                .foregroundStyle(Color.lifeTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Layout.spacingM)
        .background(Color.lifeAccent.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusM))
    }

    // MARK: - 关于

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Layout.spacingM) {
            Text("关于")
                .font(.lifeHeadline)
                .foregroundStyle(Color.lifeText)

            HStack {
                Text("人生答案之书")
                    .font(.lifeBody)
                    .foregroundStyle(Color.lifeText)
                Spacer()
                Text("v1.0")
                    .font(.lifeCaption)
                    .foregroundStyle(Color.lifeTextSecondary)
            }
        }
        .lifeCard()
    }
}
