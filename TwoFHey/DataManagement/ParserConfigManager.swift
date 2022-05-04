//
//  ConfigManager.swift
//  TwoFHey
//
//  Created by Drew Pomerleau on 5/4/22.
//

import Foundation

class ParserConfigManager: ObservableObject {
    let DEFAULT_CONFIG = OTPParserConfiguration(servicePatterns: OTPParserConstants.servicePatterns, knownServices: OTPParserConstants.knownServices)
    
    @Published var config: OTPParserConfiguration?
    
    init() {
        config = loadLocalServiceConfig() ?? DEFAULT_CONFIG
    }
    
    private var configurationFilePath: URL? {
        let documentsUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0] as NSURL
        return documentsUrl.appendingPathComponent("twofheyConfiguration.json")
    }
    
    private func loadLocalServiceConfig() -> OTPParserConfiguration? {
        guard let path = configurationFilePath, let data = try? Data(contentsOf: path) else { return nil }
        
        return try? JSONDecoder().decode(OTPParserConfiguration.self, from: data)
    }
    
    private var configURL = URL(string: "https://test.com")
    
    func downloadLatestServiceConfig() {
        guard let configURL = configURL else { return }
        
        URLSession.shared.dataTask(with: configURL) { [weak self] data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data, let decoded = try? JSONDecoder().decode(OTPParserConfiguration.self, from: data) else { return }
                
            if let configurationFilePath = self?.configurationFilePath {
                try? data.write(to: configurationFilePath)
            }

            DispatchQueue.main.async {
                self?.config = decoded
            }
        }
    }
}