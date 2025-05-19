import SwiftUI

struct MainTabBarView: View {
    enum Tab: Int, CaseIterable {
        case explore, account, aiVideo, aiHeadshots
        var title: String {
            switch self {
            case .explore: return "Explore"
            case .account: return "Account"
            case .aiVideo: return "AI Video"
            case .aiHeadshots: return "AI Headshots"
            }
        }
        var icon: String {
            switch self {
            case .explore: return "sparkles"
            case .account: return "person.circle"
            case .aiVideo: return "video"
            case .aiHeadshots: return "person.crop.square"
            }
        }
    }
    @State private var selectedTab: Tab = .explore
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .explore:
                    ThemeSelectionView()
                case .account:
                    Text("Account Page")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                case .aiVideo:
                    Text("AI Video Page")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                case .aiHeadshots:
                    Text("AI Headshots Page")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                }
            }
            .edgesIgnoringSafeArea(.all)
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \ .self) { tab in
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(selectedTab == tab ? .white : .gray)
                            Text(tab.title)
                                .font(.caption2)
                                .foregroundColor(selectedTab == tab ? .white : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .padding(.horizontal, 32)
            //.padding(.bottom, 32)
            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
        }
    }
}

#Preview {
    MainTabBarView()
} 
