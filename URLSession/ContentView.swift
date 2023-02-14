//
//  ContentView.swift
//  URLSession
//
//  Created by Andy Griffiths on 14/02/2023.
//

import SwiftUI

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}

struct ContentView: View {
    @State private var results = [Result]()
    @State private var message = "Loading..."
    
    var body: some View {
        VStack {
            Text(message)
                .task {
                    do {
                        // I think I understand async / await a bit better now.
                        // .sleep is marked async, so has to be called await
                        // and because also marked as throws, has to be 'try'ed.
                        // do {} catch {} is necessary to catch the possible throw
                        // even if I do nothing with an error.
                        try await Task.sleep(until: .now + .seconds(3), clock: .continuous)
                    } catch { }
                    message = "Woken up"
                    
                    // ofc I can convert any error to an optional, or could disable with try!
                    try? await Task.sleep(until: .now + .seconds(3), clock: .continuous)
                    message = "Had at least 2 cups of coffee"
                }
            List(results, id: \.trackId) { item in
                VStack(alignment: .leading) {
                    Text(item.trackName)
                        .font(.headline)
                    Text(item.collectionName)
                }
            }
            .task {
                // similarly I have marked loadData as async (but not throws)
                // so just await will suffice here
                await loadData()
            }
        }
    }
    
    func loadData() async {
        // loadData has to be marked async because it uses await calls
        guard let url = URL(string: "https://itunes.apple.com/search?term=electric+wizard&entity=song") else {
            print("Invalid URL")
            return
        }
        
        do {
            // Again .data is async throws, so try await in do catch
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                results = decodedResponse.results
            }
        } catch {
            print("Invalid data")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
