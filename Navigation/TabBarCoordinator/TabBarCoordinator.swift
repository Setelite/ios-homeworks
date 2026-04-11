//
//  TabBarCoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/23/26.
//

import UIKit

/// Таббар 
final class TabBarCoordinator: Coordinator {

    let tabBarController = UITabBarController()
    private var homeCoordinator: HomeCoordinator?
    private var sportsCoordinator: SportsCoordinator?
    private var chatsCoordinator: ChatsCoordinator?
    private var clipsCoordinator: ClipsCoordinator?
    private var menuCoordinator: MenuCoordinator?

    func start() {
        configureAppearance()

        let homeNav = UINavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNav)
        homeCoordinator.start()
        self.homeCoordinator = homeCoordinator
        homeNav.tabBarItem = UITabBarItem(
            title: L10n.tr("tab.home"),
            image: TabBarIconFactory.icon(for: .home, selected: false),
            selectedImage: TabBarIconFactory.icon(for: .home, selected: true)
        )

        let sportsNav = UINavigationController()
        let sportsCoordinator = SportsCoordinator(navigationController: sportsNav)
        sportsCoordinator.start()
        self.sportsCoordinator = sportsCoordinator
        sportsNav.tabBarItem = UITabBarItem(
            title: L10n.tr("tab.sports"),
            image: TabBarIconFactory.icon(for: .sports, selected: false),
            selectedImage: TabBarIconFactory.icon(for: .sports, selected: true)
        )

        let chatsNav = UINavigationController()
        let chatsCoordinator = ChatsCoordinator(navigationController: chatsNav)
        chatsCoordinator.start()
        self.chatsCoordinator = chatsCoordinator
        chatsNav.tabBarItem = UITabBarItem(
            title: L10n.tr("tab.chats"),
            image: TabBarIconFactory.icon(for: .chats, selected: false),
            selectedImage: TabBarIconFactory.icon(for: .chats, selected: true)
        )

        let clipsNav = UINavigationController()
        let clipsCoordinator = ClipsCoordinator(navigationController: clipsNav)
        clipsCoordinator.start()
        self.clipsCoordinator = clipsCoordinator
        clipsNav.tabBarItem = UITabBarItem(
            title: L10n.tr("tab.music"),
            image: TabBarIconFactory.icon(for: .music, selected: false),
            selectedImage: TabBarIconFactory.icon(for: .music, selected: true)
        )

        let menuNav = UINavigationController()
        let menuCoordinator = MenuCoordinator(navigationController: menuNav)
        menuCoordinator.start()
        self.menuCoordinator = menuCoordinator
        menuNav.tabBarItem = UITabBarItem(
            title: L10n.tr("tab.menu"),
            image: TabBarIconFactory.icon(for: .menu, selected: false),
            selectedImage: TabBarIconFactory.icon(for: .menu, selected: true)
        )

        tabBarController.viewControllers = [
            homeNav,
            sportsNav,
            chatsNav,
            clipsNav,
            menuNav
        ]
    }

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = StyleGuide.Colors.backgroundPrimary

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: StyleGuide.Fonts.caption(10, weight: .medium),
            .foregroundColor: StyleGuide.Colors.textSecondary
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .font: StyleGuide.Fonts.caption(10, weight: .medium),
            .foregroundColor: StyleGuide.Colors.accent
        ]

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        appearance.stackedLayoutAppearance.normal.iconColor = StyleGuide.Colors.textSecondary
        appearance.stackedLayoutAppearance.selected.iconColor = StyleGuide.Colors.accent
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)

        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.tintColor = StyleGuide.Colors.accent
        tabBarController.tabBar.unselectedItemTintColor = StyleGuide.Colors.textSecondary
    }
}
