//
//  AppSettingViewController.swift
//  SeSAC_ModernCollectionPractice
//
//  Created by 박태현 on 2023/09/15.
//

import UIKit

enum Item: Hashable {
    case setting(AppSettingData)
    case toggle(String)
}

struct Section: Hashable {
    let items: [Item]
    let headerTitle: String?
    let footerTitle: String?
}

struct AppSettingData: Hashable {
    let appSetting: AppSetting
    var status: String
}

enum AppSetting: CaseIterable {
    case 방해금지모드
    case 수면
    case 업무
    case 개인시간

    var title: String {
        switch self {
        case .방해금지모드: return "방해 금지 모드"
        case .수면: return "수면"
        case .업무: return "업무"
        case .개인시간: return "개인 시간"
        }
    }

    var image: UIImage {
        switch self {
        case .방해금지모드: return .init(systemName: "moon.fill")!
        case .수면: return .init(systemName: "bed.double.fill")!
        case .업무: return .init(systemName: "iphone.gen3")!
        case .개인시간: return .init(systemName: "person.fill")!
        }
    }

    var imageTintColor: UIColor {
        switch self {
        case .방해금지모드: return .systemPurple
        case .수면: return .systemOrange
        case .업무: return .systemGreen
        case .개인시간: return .systemCyan
        }
    }

    var secondaryText: String? {
        switch self {
        case .업무: return "09:00 ~ 06:00"
        default: return nil
        }
    }

    var accessoryText: String? {
        switch self {
        case .방해금지모드: return "켬"
        case .개인시간: return "설정"
        default: return nil
        }
    }
}

final class AppSettingViewController: UIViewController {

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        // lazy 키워드를 통해 뷰컨의 프로퍼티, 메소드를 초기화 전에 사용할 수 있게 함
        // lazy 키워드를 사용한 프로퍼티의 메모리 로드 시점은 초기화 이후 처음 접근하는 시점이므로 가능한 것
        // layout(CompositionalLayout - List)을 만들어서 이걸로 컬렉션뷰를 초기화!
        let layout = createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private lazy var dataSource = self.createDiffableDataSource()

    private func createLayout() -> UICollectionViewLayout {

        // CompositionalLayout의 List를 사용
        // 1. Layout Configuration을 생성(List, insetGrouped)
        // layout configuration에서 layout(collectionView)에 대한 UI속성이나 액션 설정이 가능하다.
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.showsSeparators = true
        configuration.backgroundColor = .systemBackground
        configuration.headerMode = .supplementary
        configuration.footerMode = .supplementary

        // -- leadingSwipeAction도 줄 수 있고 --
        // configuration.leadingSwipeActionsConfigurationProvider

        // -- trailingSwipeAction도 줄 수 있다 --
        // configuration.trailingSwipeActionsConfigurationProvider

        // 2. Layout Configuration을 사용해서 CompositionalLayout을 생성
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)

        return layout
    }

    private func createCellRegistration() -> UICollectionView.CellRegistration<
        UICollectionViewListCell, Item
    > {

        // 3. Cell Registration 클로저 생성
        // 제네릭으로 <셀 타입, 셀에 넣을 데이터 타입>을 명시해야 한다.
        // 클로저의 매개변수로는 (셀, 인덱스패스, 데이터)가 있음.
        let cellRegistration = UICollectionView.CellRegistration<
            UICollectionViewListCell, Item
        > { cell, indexPath, itemIdentifier in

            // 섹션(background) configuration --
            var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
            backgroundConfiguration.cornerRadius = 10
            backgroundConfiguration.backgroundColor = .secondarySystemBackground

            // background configuration 등록
            cell.backgroundConfiguration = backgroundConfiguration

            var contentConfiguration = UIListContentConfiguration.subtitleCell()

            // 셀의 content 영역 configuration --
            switch itemIdentifier {
            case .setting(let item):
                contentConfiguration.image = item.appSetting.image
                contentConfiguration.imageProperties.tintColor = item
                    .appSetting
                    .imageTintColor
                contentConfiguration.text = item.appSetting.title
                if let secondaryText = item.appSetting.secondaryText {
                    contentConfiguration.secondaryText = secondaryText
                }
                contentConfiguration.textToSecondaryTextVerticalPadding = 4.0
                contentConfiguration.textProperties.color = .label
                contentConfiguration.imageToTextPadding = 30.0

                // contentConfiguration 등록
                cell.contentConfiguration = contentConfiguration

                // cell accesories 설정
                cell.accessories = [.disclosureIndicator()]
                if let detailText = item.appSetting.accessoryText {
                    cell.accessories.append(.label(text: detailText))
                }

            case .toggle(let text):
                contentConfiguration.text = text

                cell.contentConfiguration = contentConfiguration

                // cell accesories 설정
                let switchView = UISwitch()

                cell.accessories = [
                    .disclosureIndicator(),
                    .customView(
                        configuration: .init(customView: switchView, placement: .trailing())
                    )
                ]
            }
        }

        return cellRegistration
    }

    private func makeSectionHeaderRegistration() -> UICollectionView.SupplementaryRegistration<
        UICollectionViewListCell
    > {
        // Section별 Header를 구성하기 위한 SupplementaryRegistration
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] (headerView, _, indexPath) in
            var content = UIListContentConfiguration.groupedHeader()
            content.text = self?.sections[indexPath.section].headerTitle
            content.textProperties.color = .secondaryLabel
            content.textProperties.font = .systemFont(ofSize: 14.0, weight: .regular)
            headerView.contentConfiguration = content
        }
    }

    private func makeSectionFooterRegistration() -> UICollectionView.SupplementaryRegistration<
        UICollectionViewListCell
    > {
        // Section Footer 구성
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { [weak self] (footerView, _, indexPath) in
            var content = UIListContentConfiguration.groupedFooter()
            content.text = self?.sections[indexPath.section].footerTitle
            content.textProperties.color = .secondaryLabel
            content.textProperties.font = .systemFont(ofSize: 14.0, weight: .regular)
            footerView.contentConfiguration = content
        }
    }

    private let sections = [
        Section(
            items: AppSetting
                .allCases
                .map { Item.setting(AppSettingData(appSetting: $0, status: "")) },
            headerTitle: "모드설정",
            footerTitle: "집중 모드에서는 경고 및 알림 소리가 울리지 않습니다."
        ),
        Section(
            items: [.toggle("모든 기기에서 공유")],
            headerTitle: "",
            footerTitle: "이 기기에서 집중 모드를 켜면 사용자의 다른 기기에서도 집중모드가 켜집니다."
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        configureUI()
        configureLayout()

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections(sections)

        sections.forEach {
            var sectionSnapShot = NSDiffableDataSourceSectionSnapshot<Item>()
            sectionSnapShot.append($0.items)
            dataSource.apply(sectionSnapShot, to: $0)
        }
    }

    private func createDiffableDataSource() -> UICollectionViewDiffableDataSource<
        Section, Item
    > {
        // DiffableDataSource
        // collectionView에 적용된 cellRegistration을 활용해서,
        // dequeueConfiguredReusableCell를 통해 셀을 생성한다.

        let cellRegistration = createCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in

            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }

        // 세션별 헤더 설정
        // 메서드로 생성한 SupplementaryRegistration를 통해 supplementaryViewProvider를 구성한다.
        let headerCellRegistration = makeSectionHeaderRegistration()
        let footerCellRegistration = makeSectionFooterRegistration()

        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) ->
            UICollectionReusableView? in
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerCellRegistration, for: indexPath
                )
            } else if elementKind == UICollectionView.elementKindSectionFooter {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: footerCellRegistration, for: indexPath
                )
            } else {
                return nil
            }
        }

        return dataSource
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
        title = "집중 모드"
    }

    private func configureLayout() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        [
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ].forEach { $0.isActive = true }
    }

}

