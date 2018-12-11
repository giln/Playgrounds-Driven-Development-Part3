import UIKit

@testable import AppStoreViewerFramework


let appStoreRessource = AppStoreRessource(datafetcher: NetworkFetcher())


appStoreRessource.getTopApps { (apps, error) in
    _ = apps.map { print($0.name) }
}


