//
//  UserView.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 05.05.25.
//

import SwiftUI
import SwiftData

@Model
class Post: Identifiable {
    var id: Int
    var userId: Int
    var title: String
    var body: String
    
    init(id: Int, userId: Int, title: String, body: String) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
    }
}

struct PostDTO: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

protocol NetworkService {
    associatedtype DTO: Decodable

    var url: URL? { get }
    func decode(_ data: Data) throws -> [DTO]
}


enum FetchState {
    case idle
    case loading
    case success
    case failed(Error)
}

enum NetworkingError: Error, LocalizedError {
    case invalidURL
    case badResponse(Int)
    case decodingFailed
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .badResponse(let code): return "Bad response: \(code)"
        case .decodingFailed: return "Decoding failed."
        case .unknown(let error): return error.localizedDescription
        }
    }
}

final class APIClient {
    static func fetch<Service: NetworkService>(_ service: Service) async throws -> [Service.DTO] {
        guard let url = service.url else {
            throw NetworkingError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else {
                throw NetworkingError.badResponse((response as? HTTPURLResponse)?.statusCode ?? -1)
            }

            return try service.decode(data)

        } catch let decodingError as DecodingError {
            throw NetworkingError.decodingFailed
        } catch {
            throw NetworkingError.unknown(error)
        }
    }
}


struct PostService: NetworkService {
    typealias DTO = PostDTO

    var url: URL? {
        URL(string: "https://jsonplaceholder.typicode.com/posts")
    }

    func decode(_ data: Data) throws -> [PostDTO] {
        try JSONDecoder().decode([PostDTO].self, from: data)
    }
}

@Observable
final class PostViewModel {
    var fetchState: FetchState = .idle

    @MainActor
    func fetchAndSave(context: ModelContext) async {
        fetchState = .loading

        do {
            let dtos = try await APIClient.fetch(PostService())

            for dto in dtos {
                let existing = try context.fetch(
                    FetchDescriptor<Post>(
                        predicate: #Predicate { $0.id == dto.id }
                    )
                )

                if existing.isEmpty {
                    let post = Post(id: dto.id, userId: dto.userId, title: dto.title, body: dto.body)
                    context.insert(post)
                }
            }

            try context.save()
            fetchState = .success

        } catch {
            fetchState = .failed(error)
        }
    }
}


struct UserView: View {
    @Query(sort: \Post.id) var posts: [Post]
    @Environment(\.modelContext) var context
    @State private var vm = PostViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                switch vm.fetchState {
                case .idle, .loading:
                    ProgressView("Loading...")
                    
                case .success:
                    List(posts) { post in
                        VStack(alignment: .leading) {
                            Text(post.title).font(.headline)
                            Text(post.body).font(.subheadline)
                        }
                    }
                    
                case .failed(let error):
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Posts")
            .toolbar {
                Button("Reload") {
                    Task {
                        await vm.fetchAndSave(context: context)
                    }
                }
            }
            .task {
                if posts.isEmpty {
                    await vm.fetchAndSave(context: context)
                } else {
                    vm.fetchState = .success
                }
            }
        }
    }
}

#Preview {
    UserView()
}
