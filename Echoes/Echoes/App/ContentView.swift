import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Hem", systemImage: "house.fill")
                    }

                MapView()
                    .tabItem {
                        Label("Utforska", systemImage: "map")
                    }

                RecordView()
                    .tabItem {
                        Label("Spela in", systemImage: "mic.fill")
                    }

                RouteListView()
                    .tabItem {
                        Label("Rutter", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    }

                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person")
                    }
            }
            .tint(AppColors.primary)
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
