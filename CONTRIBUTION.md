Few simple rules to make code happy :)

# Dev-Checklist

1. Write code according to [Effective dart](https://dart.dev/guides/language/effective-dart)
2. Ensure that auto-formatting enabled in your IDE
3. Ensure that ALL existing tests passed
4. Write test to cover features/bugs
5. Keep CI green

# When feature is merged (just for owner)

TODO: automate workflow with github action

 - Update changelog
 - Increase version in pubspec.yaml
 - Create commit & tag
 - Test publish with `dart pub publish --dry-run`
 - Publish new build to pub.dev with `dart pub publish`