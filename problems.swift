import Foundation

func innerThreadCancelationProblem() {
    let thread = Thread {
        let start = Date()
        Thread.sleep(forTimeInterval: 1)
        print("Slept for", Date().timeIntervalSince(start))
        Thread.detachNewThread {
            print("Inner thread isCancelled", Thread.current.isCancelled)
        }
        guard !Thread.current.isCancelled
        else {
            print("Cancelled")
            return
        }
        print(Thread.current)
    }
    thread.start()
    Thread.sleep(forTimeInterval: 0.1)
    thread.cancel()
}

// innerThreadCancelationProblem()
// Thread.sleep(forTimeInterval: 2)

func thredExpensivenessProblem(workCount: Int) {
    for n in 0..<workCount {
        Thread.detachNewThread {
            print(n, Thread.current, "stack size: \(Thread.current.stackSize)")
            while true { } // Some serious work
        }
    }
}

// thredExpensivenessProblem(workCount: 1_000)
// Thread.sleep(forTimeInterval: 5)

func nthPrime(_ n: Int) {
    
    func isPrime(_ p: Int) -> Bool {
        if p <= 1 { return false }
        if p <= 3 { return true }
        for i in 2...Int(sqrtf(Float(p))) {
            if p % i == 0 { return false }
        }
        return true
    }
    
    let start = Date()
    var primeCount = 0
    var prime = 2
    
    while primeCount < n {
        defer { prime += 1 }
        if isPrime(prime) {
            primeCount += 1
        }
    }
    
    print("\(n)th prime", prime-1, "time", Date().timeIntervalSince(start))
}

// thredExpensivenessProblem(workCount: 1_000)
// Thread.detachNewThread {
//     print("Starting prime thread")
//     nthPrime(50_000)
// }
// Thread.sleep(forTimeInterval: 10)

func defaultThreadRacingProblem() {
    class Counter {
        var count = 0
    }
    let counter = Counter()
    
    for _ in 0..<1_000 {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            counter.count += 1
        }
    }
    
    Thread.sleep(forTimeInterval: 1)
    print(counter.count)
}

// defaultThreadRacingProblem()

func solvingThreadRacingProblemWithLock() {
    class Counter {
        let lock = NSLock()
        private(set) var count = 0
        
        func increment() {
            self.lock.lock()
            defer { self.lock.unlock() }
            self.count += 1
        }
    }
    
    let counter = Counter()

    for _ in 0..<1_000 {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            counter.increment()
        }
    }

    Thread.sleep(forTimeInterval: 1)
    print(counter.count)
}

// solvingThreadRacingProblemWithLock()

func getterSetterThreadRacingProblem() {
    class Counter {
        let lock = NSLock()
        private var _count = 0
        var count: Int {
            get {
                self.lock.lock()
                defer { self.lock.unlock() }
                return self._count
            }
            set {
                self.lock.lock()
                defer { self.lock.unlock() }
                self._count = newValue
            }
        }
    }
    
    let counter = Counter()

    for _ in 0..<1_000 {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            counter.count += 1
        }
    }

    Thread.sleep(forTimeInterval: 1)
    print(counter.count)
}

// getterSetterThreadRacingProblem()

func yieldingModifiersProblem() {
    class Counter {
        let lock = NSLock()
        private var _count = 0
        var count: Int {
            _read {
                self.lock.lock()
                defer { self.lock.unlock() }
                yield self._count
            }
            _modify {
                self.lock.lock()
                defer { self.lock.unlock() }
                yield &self._count
            }
        }
    }
    
    let counter = Counter()
    
    for _ in 0..<1_000 {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            counter.count += 1
            // counter.count += 1 + counter.count / 100
        }
    }
    
    Thread.sleep(forTimeInterval: 1)
    print(counter.count)
}

// yieldingModifiersProblem()
