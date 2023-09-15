//
//  AppSettingViewController.swift
//  SeSAC_ModernCollectionPractice
//
//  Created by 박태현 on 2023/09/15.
//

import UIKit

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
}

final class AppSettingViewController: UIViewController {

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        // lazy 키워드를 통해 뷰컨의 프로퍼티, 메소드를 초기화 전에 사용할 수 있게 함
        // lazy 키워드를 사용한 프로퍼티의 메모리 로드 시점은 초기화 이후 처음 접근하는 시점이므로 가능한 것
        let layout = createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private lazy var dataSource = self.createDiffableDataSource()

    private func createLayout() -> UICollectionViewLayout {
        // CompositionalLayout의 List를 사용
        // 1. Layout Configuration을 생성(List, insetGrouped)
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.showsSeparators = true
        configuration.backgroundColor = .systemBackground

        // 2. Layout Configuration을 사용해서 CompositionalLayout을 생성
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }

    private func createCellRegistration() -> UICollectionView.CellRegistration<
        UICollectionViewListCell, AppSettingData
    > {
        // 3. Cell Registration 클로저 생성
        // 제네릭으로 셀 타입, 셀에 넣을 데이터 타입을 명시해야 한다.
        // 클로저의 매개변수로는 셀, 인덱스패스, 데이터가 있음.
        let cellRegistration = UICollectionView.CellRegistration<
            UICollectionViewListCell, AppSettingData
        > { cell, indexPath, itemIdentifier in

            // 셀의 content 영역 configuration
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.image = itemIdentifier.appSetting.image
            contentConfiguration.imageProperties.tintColor = itemIdentifier
                .appSetting
                .imageTintColor
            contentConfiguration.text = itemIdentifier.appSetting.title

            // contentConfiguration 등록
            cell.contentConfiguration = contentConfiguration

            // 섹션(background) configuration
            var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
            backgroundConfiguration.backgroundColor = .lightGray
            backgroundConfiguration.cornerRadius = 10

            // background configuration 등록
            cell.backgroundConfiguration = backgroundConfiguration

        }

        return cellRegistration
    }

    private let items = AppSetting.allCases.map { AppSettingData(appSetting: $0, status: "") }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        configureLayout()

        var snapshot = NSDiffableDataSourceSnapshot<Int, AppSettingData>()

        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)

        dataSource.apply(snapshot)
    }

    private func createDiffableDataSource() -> UICollectionViewDiffableDataSource<
        Int, AppSettingData
    > {
        // DiffableDataSource
        // collectionView에 적용된 cellRegistration을 활용해서,
        // dequeueConfiguredReusableCell를 통해 셀을 생성한다.

        let cellRegistration = createCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<Int, AppSettingData>(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in

            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )

            return cell
        }

        return dataSource
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

