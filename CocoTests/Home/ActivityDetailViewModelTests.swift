//
//  ActivityDetailViewModelTests.swift
//  CocoTests
//

import Foundation
import Testing
@testable import Coco

struct ActivityDetailViewModelTests {

    // MARK: - Helpers
    private func makeDetailData() throws -> ActivityDetailDataModel {
        let list: ActivityModelArray = try JSONReader.getObjectFromJSON(with: "activities")
        #expect(!list.values.isEmpty)
        return ActivityDetailDataModel(list.values[0])
    }

    private struct Ctx {
        let fetcher: MockActivityDetailViewModel
        let vm: ActivityDetailViewModel
        let action: MockAction
        let nav: MockNav
        let data: ActivityDetailDataModel

        static func setup() throws -> Ctx {
            let fetcher = MockActivityDetailViewModel()
            let data = try ActivityDetailViewModelTests().makeDetailData()
            let vm = ActivityDetailViewModel(data: data)
            let action = MockAction()
            let nav = MockNav()
            vm.actionDelegate = action
            vm.navigationDelegate = nav
            return Ctx(fetcher: fetcher, vm: vm, action: action, nav: nav, data: data)
        }
    }

    // MARK: - onViewDidLoad

    @Test("onViewDidLoad - mengirim configureView(data:) sekali dengan data yang sama")
    func onViewDidLoad_shouldConfigureView() throws {
        // --- GIVEN ---
        let c = try Ctx.setup()

        // --- WHEN ---
        c.vm.onViewDidLoad()

        // --- THEN ---
        #expect(c.action.configureViewCount == 1)
        #expect(c.action.lastConfiguredData == c.data)
    }

    // MARK: - Navigasi paket detail

    @Test("onPackagesDetailDidTap - when user not logged in should navigate to login")
    func tapPackage_whenNotLoggedIn_shouldNavigateToLogin() throws {
        // --- GIVEN ---
        let c = try Ctx.setup()
        // Clear any existing user-id to simulate not logged in state
        UserDefaults.standard.removeObject(forKey: "user-id")

        // --- WHEN ---
        c.vm.onPackagesDetailDidTap(with: 99)

        // --- THEN ---
        // Should attempt to show login popup (navigateToLogin will be called)
        #expect(c.nav.navigateToLoginCount == 1)
        #expect(c.nav.didSelectCount == 0) // Should not navigate to package selection
    }
    
    @Test("onPackagesDetailDidTap - when user logged in should forward to navigation")
    func tapPackage_whenLoggedIn_shouldForwardToNavigation() throws {
        // --- GIVEN ---
        let c = try Ctx.setup()
        // Simulate logged in state
        UserDefaults.standard.setValue("test-user-123", forKey: "user-id")

        // --- WHEN ---
        c.vm.onPackagesDetailDidTap(with: 99)

        // --- THEN ---
        #expect(c.nav.didSelectCount == 1)
        #expect(c.nav.lastSelectedId == 99)
        #expect(c.nav.lastPackage == c.data)
        #expect(c.nav.navigateToLoginCount == 0) // Should not call login
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "user-id")
    }
}

// MARK: - Mocks

private final class MockAction: ActivityDetailViewModelAction {
    private(set) var configureViewCount = 0
    private(set) var lastConfiguredData: ActivityDetailDataModel?

    func configureView(data: ActivityDetailDataModel) {
        configureViewCount += 1
        lastConfiguredData = data
    }

    private(set) var updatePackageDataCount = 0
    private(set) var lastPackages: [ActivityDetailDataModel.Package] = []

    func updatePackageData(data: [ActivityDetailDataModel.Package]) {
        updatePackageDataCount += 1
        lastPackages = data
    }
}

private final class MockNav: ActivityDetailNavigationDelegate {
    private(set) var didSelectCount = 0
    private(set) var lastPackage: ActivityDetailDataModel?
    private(set) var lastSelectedId: Int?
    private(set) var navigateToLoginCount = 0

    func notifyActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int) {
        didSelectCount += 1
        lastPackage = package
        lastSelectedId = selectedPackageId
    }
    
    func navigateToLogin() {
        navigateToLoginCount += 1
    }
}
