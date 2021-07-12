import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// MARK: - COLLECT

example(of: "collect") {
    ["A", "B", "C", "D", "E"].publisher
        .collect(2)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "map") {
    //1 Create a number formatter to spell out each number
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    // 2 Create a publisher of integers
    [123, 4, 56].publisher
    
    // 3 use map passing a closure to get upstream values and return the result of using the formatter to return the number's spelled out string
        .map {
            formatter.string(from: NSNumber(integerLiteral: $0)) ?? ""
        }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "map key paths") {
    // 1 Create a publisher of coordinate that will never emit an error
    let publisher = PassthroughSubject<Coordinate, Never>()
   
    // 2 Begin a subscription to the publisher 
    publisher
        // 3
        .map(\.x, \.y)
        .sink(receiveValue: { x, y in
            // 4
            print("The coordinate at (\(x), \(y)) is a quardant",
                  quadrantOf(x: x, y: y)
            )
        })
        .store(in: &subscriptions)
    
    // 5
    publisher.send(Coordinate(x: 10, y: -8))
    publisher.send(Coordinate(x: 0, y: 5))
}

example(of: "tryMap") {
    // 1 Create a publisher of string representing directory name that does nort exist
    Just("Directory name that does not exist")
    // 2 USe try map to attempt to get the content of that nonexistent directory
        .tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
    // 3 Receive and print ou any values or completion event
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "flatMap") {
    // 1 Define func that take an array of integer, each reprendting ASCII code,
    // and returns a type-erased publisher of string that never emit error
    func decode(_ codes: [Int]) -> AnyPublisher<String, Never> {
        // 2 Create just publisher convert the character code to string
        Just(
            codes
                .compactMap { code in
                    guard (32...255).contains(code) else { return nil }
                    return String(UnicodeScalar(code) ?? " ")
                }
                // 3 joined string
                    .joined()
            )
        // 4 type erase publisher to match return type
        .eraseToAnyPublisher()
    }
    
    // 5
    [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]
        .publisher
        .collect()

        .flatMap(decode)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}


example(of: "replaceNil") {
    // 1 Create a publisher from an array of optional strings
    ["A", nil, "B"].publisher
        .eraseToAnyPublisher()
        .replaceNil(with: "-") // 2 USe replace(with:) to replace nil value
        .sink(receiveValue: { print($0) }) // 3 print out value
        .store(in: &subscriptions)
}


example(of: "replaceEmppty(with:)") {
    // 1 create empty publisher
    let empty = Empty<Int, Never>()
    
    // 2 subscribe to it and print received event 
    empty
        .replaceEmpty(with: 1)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}


/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
