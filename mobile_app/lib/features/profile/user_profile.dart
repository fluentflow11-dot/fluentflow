class UserProfile {
	UserProfile({required this.uid, required this.name, required this.birthdateMillis, this.photoUrl});

	final String uid;
	final String name;
	final int birthdateMillis; // UTC epoch millis
	final String? photoUrl;

	Map<String, Object?> toMap() => {
		'uid': uid,
		'name': name,
		'birthdateMillis': birthdateMillis,
		'photoUrl': photoUrl,
	};

	static UserProfile fromMap(Map<String, Object?> data) {
		return UserProfile(
			uid: (data['uid'] as String?) ?? '',
			name: (data['name'] as String?) ?? '',
			birthdateMillis: (data['birthdateMillis'] as int?) ?? 0,
			photoUrl: data['photoUrl'] as String?,
		);
	}
}


