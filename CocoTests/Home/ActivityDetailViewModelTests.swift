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

    @Test("onPackagesDetailDidTap - meneruskan id & paket ke navigation delegate")
    func tapPackage_shouldForwardToNavigation() throws {
        // --- GIVEN ---
        let c = try Ctx.setup()

        // --- WHEN ---
        c.vm.onPackagesDetailDidTap(with: 99)

        // --- THEN ---
        #expect(c.nav.didSelectCount == 1)
        #expect(c.nav.lastSelectedId == 99)
        #expect(c.nav.lastPackage == c.data)
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

    func notifyActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int) {
        didSelectCount += 1
        lastPackage = package
        lastSelectedId = selectedPackageId
    }
}
