import SwiftUI

struct MainTabView: View {
    let profile: UserProfile
    let finance: FinanceStore

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(profile: profile, finance: finance)
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }

            NavigationStack {
                MovementsView(finance: finance)
            }
            .tabItem {
                Label("Movimientos", systemImage: "arrow.left.arrow.right")
            }

            NavigationStack {
                InvestmentsView()
            }
            .tabItem {
                Label("Inversiones", systemImage: "chart.line.uptrend.xyaxis")
            }

            NavigationStack {
                ProfileView(profile: profile)
            }
            .tabItem {
                Label("Ajustes", systemImage: "person.fill")
            }
        }
        .tint(VestaTheme.forest)
        .toolbarBackground(VestaTheme.cream, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
