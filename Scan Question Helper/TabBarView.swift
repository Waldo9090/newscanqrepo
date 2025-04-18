//
//  TabBarView.swift
//  AI Homework Helper
//
//  Created by Ayush Mahna on 2/2/25.
//

import SwiftUI
import SuperwallKit

struct TabBarView: View {
    @State private var selectedTab: Int = 0
    @State private var showCameraView = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // Discover Tab
                NavigationStack {
                    DiscoverView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "square.stack.fill" : "square.stack")
                        Text("Discover")
                    }
                }
                .tag(0)
                
                // Chat Tab
                NavigationStack {
                    ChatListView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right")
                        Text("Chat")
                    }
                }
                .tag(1)
                
                // History Tab
                NavigationStack {
                    HistoryView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "clock.fill" : "clock")
                        Text("History")
                    }
                }
                .tag(2)
                
                // Profile Tab
                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                        Text("Profile")
                    }
                }
                .tag(3)
            }
            .accentColor(.purple)
            .onAppear {
                // Register Superwall event
                Superwall.shared.register(placement: "campaign_trigger")
                
                // Customize tab bar appearance
                let appearance = UITabBarAppearance()
                appearance.backgroundColor = .black
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            // Custom center scan button overlay
            Button(action: {
                showCameraView = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 2)
                    
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -30)
            .fullScreenCover(isPresented: $showCameraView) {
                CameraView()
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
