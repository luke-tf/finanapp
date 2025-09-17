#!/bin/bash

echo "🧪 Running FinanApp Test Suite..."

# Run unit tests
echo "📊 Running Unit Tests..."
flutter test test/unit/ --coverage

# Run widget tests  
echo "🎨 Running Widget Tests..."
flutter test test/widget/

# Run golden tests
echo "🖼️  Running Golden Tests..."
flutter test test/golden/ --update-goldens

# Run integration tests
echo "🔄 Running Integration Tests..."
flutter test test/integration/

echo "✅ All tests completed!"