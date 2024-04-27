#!/usr/bin/env swift

import Foundation

// MARK: All structs

struct Config {
    static let key: String = ""
}
struct Tasks: Codable {
    let tasks: [Task]
}

struct Projects: Codable {
    let projects: [Task]
}

struct Task: Codable {
    let id: Int?
    let name, code: String?

    enum CodingKeys: String, CodingKey {
        case id, name, code
    }
}

struct CommandLineArgs {
    let command: String
    let parameters: [String]
}

func getCurrentDateString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: Date())
    return dateString
}

func parseCommandLine() -> CommandLineArgs {
    let arguments = CommandLine.arguments
    guard arguments.count >= 2 else {
        return CommandLineArgs(command: "--help", parameters: [])
    }

    if arguments[1].hasPrefix("-") {
        return CommandLineArgs(command: arguments[1], parameters: Array(arguments.dropFirst(2)))
    } else {
        return CommandLineArgs(command: arguments[1], parameters: Array(arguments.dropFirst(2)))
    }
}

func request<T: Decodable>(configuration: URLRequest) async throws -> Result<T, Error> {
    do {
        let session = URLSession.shared
        let (data, _) = try await session.data(for: configuration)
        return try .success(JSONDecoder().decode(T.self, from: data))
    } catch {
        return .failure(error)
    }
}

func prepare(url: String,
             method: String = "GET",
             data: [String: Any] = [:],
             key: String = Config.key) -> URLRequest?
{
    guard let url = URL(string: url) else {
        return nil
    }

    var request = URLRequest(url: url)

    let loginString = "\(key):\(key)"
    guard let loginData = loginString.data(using: .utf8) else {
        print("Invalid username or password")
        return nil
    }

    let credentials = loginData.base64EncodedString()
    request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpMethod = method
    if !data.isEmpty {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = jsonData
        } catch {}
    }
    return request
}

func handleCommand(command: String, parameters: [String]) async {
    switch command {
    case "-h", "--help":
        printUsage()
    case "projects":
        if let urlRequest = prepare(url: "https://app.paymoapp.com/api/projects") {
            do {
                let result: Result<Projects, Error> = try await request(configuration: urlRequest)
                switch result {
                case let .success(response):
                    for value in response.projects {
                        print(value.id ?? 0, " -- ", value.name ?? "")
                    }
                case .failure:
                    break
                }
            } catch {}
        }
    case "tasks":
        if let urlRequest = prepare(url: "https://app.paymoapp.com/api/tasks") {
            do {
                let result: Result<Tasks, Error> = try await request(configuration: urlRequest)
                switch result {
                case let .success(response):
                    for value in response.tasks {
                        print(value.id ?? 0, " -- ", value.name ?? "")
                    }
                case .failure:
                    break
                }
            } catch {}
        }
    case "add":
        guard parameters.count >= 4 else {
            print("Insufficient parameters provided.")
            return
        }

        var components = URLComponents(string: "https://app.paymoapp.com/api/entries")!

        var date: String = getCurrentDateString()

        if parameters[1] != "today" {
            date = parameters[1]
        }

        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "task_id", value: parameters[0]),
            URLQueryItem(name: "date", value: date),
            URLQueryItem(name: "duration", value: parameters[2]),
            URLQueryItem(name: "description", value: parameters[3]),
        ]

        components.queryItems = queryItems

        if let urlRequest = prepare(url: components.string ?? "", method: "POST") {
            do {
                let session = URLSession.shared
                let (data, _) = try await session.data(for: urlRequest)
                print(String(data: data, encoding: .utf8) ?? "")
            } catch {
                print(error)
            }
        }
    default:
        print("Unknown command: \(command)", parameters)
    }
}

func printUsage() {
    print("Usage: ./main.swift <command> <parameters>")
    print("Available commands:")
    print()
    print("app tasks - show all tasks")
    print("app projects - show all projects")
    print("app add - add time to paymo with any format")
    print("set task id, date (also you can set today), duration, comment")
    print("./main.swift add 25548372 \"2024-04-25\" 32400 \"hello world\"")
}

func main() async {
    let commandLineArgs = parseCommandLine()
    await handleCommand(command: commandLineArgs.command,
                        parameters: commandLineArgs.parameters)
}

await main()
