//
//  ContentView.swift
//  ProgrammaticMenu
//
//  Created by Devon Martin on 6/7/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: Colors - add to Assets
    private let dividerLight = Color(red: 0.7, green: 0.7, blue: 0.7)
    private let dividerDark = Color(red: 0.375, green: 0.375, blue: 0.375)
    private let menuCellBackgroundLightUntapped = Color(red: 0.96, green: 0.96, blue: 0.96).opacity(0.995)
    private let menuCellBackgroundDarkUntapped = Color(red: 0.1215, green: 0.1215, blue: 0.1215).opacity(0.99)
    private let menuCellBackgroundLightTapped = Color(red: 0.9, green: 0.9, blue: 0.9)
    private let menuCellBackgroundDarkTapped = Color(red: 0.21, green: 0.21, blue: 0.21)
    
    // MARK: State variables
    @State private var hasAppeared = false // Only run animation once - update in onAppear
    
    @State private var navPath = NavigationPath()
    
    @State private var toolbarImageOpacity: Double = 1
    @State private var menuOpacity: Double = 0
    @State private var menuScale: Double = 0.2
    
    @State private var menuCellBackgroundLight: Color!
    @State private var menuCellBackgroundDark: Color!
    
    // MARK: Adjustable timing for the triggering of animations
    private let delayToToggleMenu: Double = 1.5
    private let delayToTapBlankButton: Double = 3
    
    init() {
        menuCellBackgroundLight = menuCellBackgroundLightUntapped
        menuCellBackgroundDark = menuCellBackgroundDarkUntapped
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            Text("Main View")
                .navigationTitle("Title")
                .navigationDestination(for: Int.self) { _ in
                    Text("Detail View")
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "plus.bubble")
                            .foregroundColor(colorScheme == .light ? .blue : .white)
                            .opacity(toolbarImageOpacity)
                            .onTapGesture {
                                toggleMenu()
                            }
                    }
                }
        }
        .overlay(alignment: .topTrailing) {
            menu()
                .opacity(menuOpacity)
                .scaleEffect(menuScale, anchor: .topTrailing)
                .offset(x: 10, y: 25)
        }
        .onAppear { // Start animation here.
            if !hasAppeared { // Only run animations once.
                hasAppeared = true
                DispatchQueue.main.asyncAfter(deadline: .now() + delayToToggleMenu) {
                    toggleMenu()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delayToTapBlankButton) {
                    tapBlankButton()
                }
            }
        }
    }
    
    private func toggleMenu() {
        withAnimation(.easeInOut(duration: 0.25)) { // 0.25 duration approximately matches the speed of a legit Menu appearing. My custom Menu does not quite match the animation of a legit Menu. An actual Menu seems to expand mostly to the left, and somewhat to the right, rather than strictly to the left. I tried playing with Offset, but I couldn't match the behavior.
            toolbarImageOpacity = 1.4 - toolbarImageOpacity
            menuOpacity = 1 - menuOpacity
        }
        withAnimation(.interpolatingSpring(stiffness: 250, damping: 25)) { // Spring animation is not pixel-perfect to an actual Menu, but it's close. Might be slightly springier.
            menuScale = 1.2 - menuScale
        }
    }
    
    private func tapBlankButton() {
        menuCellBackgroundLight = menuCellBackgroundLightTapped
        menuCellBackgroundDark = menuCellBackgroundDarkTapped
        toggleMenu()
        DispatchQueue.main.async() {
            navPath.append(1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Reset cell background color after Menu disappears
            menuCellBackgroundLight = menuCellBackgroundLightUntapped
            menuCellBackgroundDark = menuCellBackgroundDarkUntapped
        }
    }
    
    private func menu() -> some View {
        
        VStack {
            HStack {
                Text("Blank")
                Spacer()
                Image(systemName: "bubble.left")
            }
            .padding(.horizontal)
            .padding(.top, 11)
            .background {
                (colorScheme == .light ? menuCellBackgroundLight : menuCellBackgroundDark)
                    .frame(height: 54) // This allows the first Cell to fade to the right color upon "tapping." 56 will have to be adjusted to get it to work on other Cells. Probably. I haven't checked. But this snugs up the Color perfectly to the Divider.
            }
            
            Divider()
                .overlay(colorScheme == .light ? dividerLight : dividerDark)
            
            NavigationLink {
                EmptyView()
            } label: {
                HStack {
                    Text("Prompt")
                    Spacer()
                    Image(systemName: "text.bubble")
                }
                .offset(y: 1)
            }
            .padding(.horizontal)
            .padding(.top, 3)
            
            Divider()
                .overlay(colorScheme == .light ? dividerLight : dividerDark)
            
            NavigationLink {
                EmptyView()
            } label: {
                HStack {
                    Text("Random")
                    Spacer()
                    Image(systemName: "dice")
                }
                .offset(y: 3)
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
        }
        .frame(width: 252) // This is the width of an actual Menu with the Cells shown. This may need to be adjusted depending on your Cell content.
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding()
        .foregroundColor(colorScheme == .light ? .black : .white)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .light ? menuCellBackgroundLightUntapped : menuCellBackgroundDarkUntapped)
                .shadow(color: .black.opacity(0.15), radius: 50) // Don't think this is pixel-perfect match to the legit Menu, but it's close enough for me.
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ContentView()
                .environment(\.colorScheme, colorScheme)
                .previewDisplayName("\(String(describing: colorScheme))")
        }
    }
}
