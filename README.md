# Paymo Time Tracker

This is a simple command-line application written in Swift that allows you to interact with the Paymo API. With this tool, you can view your tasks and projects, as well as add time entries to your Paymo account.

## Requirements

- Swift 5.5 or later
- macOS 12.0 or later

## Installation

1. Clone the repository: `git clone https://github.com/tinyprocessing/TinyPaymo.git`
2. Navigate to the project directory: `cd TinyPaymo`
3. Build the project: `swift build`
4. Run the application: `.build/debug/TinyPaymo`

## Usage

The application accepts various commands and parameters to perform different actions. Here's a list of available commands:

- `tasks`: Display all tasks in your Paymo account.
- `projects`: Display all projects in your Paymo account.
- `add`: Add a time entry to your Paymo account.

### Displaying Tasks and Projects

To display tasks or projects, simply run the application with the respective command:

```sh
./main.swift tasks
./main.swift projects
```

The application will display a list of tasks or projects along with their IDs and names.

### Adding Time Entries

To add a time entry, use the `add` command followed by the required parameters:

```sh
./main.swift add <task_id> <date> <duration> <description>
```

Replace `<task_id>` with the ID of the task you want to add time to, `<date>` with the date of the time entry (in the format `YYYY-MM-DD`), `<duration>` with the duration of the time entry in seconds, and `<description>` with a brief description of the time entry.

For example:

```sh
./main.swift add 12345678 "2022-12-31" 3600 "Worked on project X"
```

This will add a one-hour time entry to task ID `12345678` on December 31, 2022, with the description "Worked on project X".

If you want to add time for today, you can use the keyword `today` instead of a specific date:

```sh
./main.swift add 12345678 today 3600 "Worked on project X"
```

## Configuration

The application uses a `Config` struct to store your Paymo API key. Replace the empty string in the `Config.key` property with your actual API key:

```swift
struct Config {
    static let key: String = "your_api_key_here"
}
```

## Code Overview

The application is structured around several Swift files:

- `main.swift`: The entry point of the application. It parses command-line arguments, handles commands, and interacts with the Paymo API.
- `Task.swift`, `Projects.swift`, and `Tasks.swift`: Swift structs that conform to the `Codable` protocol, representing the data models used for decoding JSON responses from the Paymo API.
- `CommandLineArgs.swift`: A struct that represents command-line arguments passed to the application.
- `Helpers.swift`: A collection of helper functions used throughout the application, such as date formatting, command-line argument parsing, and API request handling.

The application uses Swift's new async/await syntax for handling asynchronous tasks, such as making API requests and processing their responses.
