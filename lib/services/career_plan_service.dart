import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:genai/genai.dart';
import '../models/career_plan.dart';

class CareerPlanService {
  // Get AI settings from Firestore for current user
  static Future<Map<String, String>> _getAISettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('ai_settings')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw Exception(
          'AI settings not configured. Please configure API key in settings.',
        );
      }

      final data = doc.data()!;
      return {
        'apiKey': data['apiKey'] ?? '',
        'provider': data['provider'] ?? 'gemini',
        'model': data['model'] ?? 'gemini-2.5-flash',
        'language': data['language'] ?? 'turkish',
      };
    } catch (e) {
      throw Exception('Failed to load AI settings: $e');
    }
  }

  // Collect user data from Firestore
  static Future<Map<String, dynamic>> collectUserData(String userId) async {
    List<Map<String, dynamic>> courses = [];
    List<Map<String, dynamic>> programItems = [];
    List<Map<String, dynamic>> previousPlans = [];

    // Get user's course schedule (try both userId and studentNumber)
    try {
      final coursesSnapshot = await FirebaseFirestore.instance
          .collection('course_schedules')
          .where('userId', isEqualTo: userId)
          .get();

      courses = coursesSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching courses: $e');
      // Continue without courses if there's an error
    }

    // Get user's program items (weekly plans)
    try {
      final programSnapshot = await FirebaseFirestore.instance
          .collection('program_items')
          .where('userId', isEqualTo: userId)
          .get();

      programItems = programSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching program items: $e');
      // Continue without program items if there's an error
    }

    // Get user's previous career plans (to understand preferences)
    try {
      final careerPlansSnapshot = await FirebaseFirestore.instance
          .collection('career_plans')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      previousPlans = careerPlansSnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Error fetching previous plans: $e');
      // Continue without previous plans if there's an error
    }

    return {
      'courses': courses,
      'programItems': programItems,
      'previousPlans': previousPlans,
    };
  }

  // Create a summary of user data for AI
  static String createUserDataSummary(Map<String, dynamic> userData) {
    StringBuffer summary = StringBuffer();

    summary.writeln('=== User Academic Profile ===\n');

    // Courses
    final courses = userData['courses'] as List<Map<String, dynamic>>;
    if (courses.isNotEmpty) {
      summary.writeln('Current Courses:');
      for (var course in courses) {
        summary.writeln(
          '- ${course['courseName']} (${course['courseCode']}) with ${course['instructor']}',
        );
      }
      summary.writeln();
    }

    // Program items (weekly plans and activities)
    final programItems = userData['programItems'] as List<Map<String, dynamic>>;
    if (programItems.isNotEmpty) {
      summary.writeln('Weekly Activities and Plans:');
      for (var item in programItems) {
        summary.writeln(
          '- ${item['title']} on ${item['date']} at ${item['time']}',
        );
      }
      summary.writeln();
    }

    // Previous career plans (to understand past interests)
    final previousPlans =
        userData['previousPlans'] as List<Map<String, dynamic>>;
    if (previousPlans.isNotEmpty) {
      summary.writeln('Previous Career Interests:');
      for (var plan in previousPlans) {
        if (plan['careerPaths'] != null) {
          summary.writeln(
            '- Career paths explored: ${(plan['careerPaths'] as List).join(', ')}',
          );
        }
      }
      summary.writeln();
    }

    return summary.toString();
  }

  // Generate career plan using AI
  static Future<Map<String, dynamic>> generateCareerPlanWithAI(
    String userDataSummary,
  ) async {
    try {
      // Get user's AI settings
      final settings = await _getAISettings();
      final apiKey = settings['apiKey']!;
      final provider = settings['provider']!;
      final model = settings['model']!;
      final language = settings['language']!;

      if (apiKey.isEmpty) {
        throw Exception('API key is empty. Please configure in settings.');
      }

      // Map language code to full language name
      final languageNames = {
        'turkish': 'Turkish',
        'english': 'English',
        'german': 'German',
        'french': 'French',
        'spanish': 'Spanish',
        'italian': 'Italian',
        'arabic': 'Arabic',
        'russian': 'Russian',
        'chinese': 'Chinese',
        'japanese': 'Japanese',
      };
      final languageName = languageNames[language] ?? 'Turkish';

      final prompt =
          '''
You are a career counselor analyzing a student's academic profile to provide personalized career guidance.

IMPORTANT: Respond in $languageName language. All your responses must be in $languageName.

Here is the student's data:
$userDataSummary

Based on this information, please provide:
1. A comprehensive career advice paragraph (at least 150 words)
2. 3-5 possible career paths that align with their courses and activities
3. 5-7 specific skills they should develop
4. Short-term goals (3-6 months)
5. Medium-term goals (6-12 months)
6. Long-term goals (1-3 years)

IMPORTANT:  Your response MUST be JSON with the following structure:
{
  "careerAdvice": "detailed advice here",
  "careerPaths": ["path1", "path2", "path3"],
  "skillsToDevelop": ["skill1", "skill2", "skill3", "skill4", "skill5"],
  "goals": {
    "short": "short term goals",
    "medium": "medium term goals",
    "long": "long term goals"
  }
}

IMPORTANT: If there is exception, add exception message to careerAdvice and return valid JSON with empty structure.
''';

      // Map provider string to ModelAPIProvider enum
      ModelAPIProvider apiProvider;
      String url;

      switch (provider) {
        case 'openai':
          apiProvider = ModelAPIProvider.openai;
          url = kOpenAIUrl;
          break;
        case 'anthropic':
          apiProvider = ModelAPIProvider.anthropic;
          url = kAnthropicUrl;
          break;
        case 'gemini':
        default:
          apiProvider = ModelAPIProvider.gemini;
          url = kGeminiUrl;
          break;
      }

      // Create AI request using genai package
      final request = AIRequestModel(
        modelApiProvider: apiProvider,
        model: model,
        apiKey: apiKey,
        url: url,
        systemPrompt:
            "You are a helpful career counselor providing personalized guidance to students.",
        userPrompt: prompt,
        stream: false,
        modelConfigs: [
          kDefaultModelConfigTemperature.copyWith(
            value: ConfigSliderValue(value: (0, 0.7, 1)),
          ),
          kDefaultGeminiModelConfigMaxTokens.copyWith(
            value: ConfigNumericValue(value: 2048),
          ),
        ],
      );

      print('Using AI provider: $provider, model: $model'); // Debug log

      // Execute request
      final answer = await executeGenAIRequest(request);

      print('Gemini API response received'); // Debug log

      if (answer != null && answer.isNotEmpty) {
        // Extract JSON from the response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(answer);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          return jsonDecode(jsonStr);
        } else {
          // If no JSON found, return the raw text as career advice
          print('Could not parse JSON from AI response. Using raw text.');
          print('AI Response: $answer');
          return {
            'careerAdvice': answer,
            'careerPaths': [],
            'skillsToDevelop': [],
            'goals': {'short': '', 'medium': '', 'long': ''},
          };
        }
      } else {
        throw Exception('No response text from AI API');
      }
    } catch (e) {
      print('Error generating career plan with AI: $e');
      // Return a fallback response if API fails
      return {
        'careerAdvice':
            'Based on your current academic profile, you have diverse interests and are developing valuable skills. Continue to explore different areas and build a strong foundation in your current courses.',
        'careerPaths': [
          'Software Development',
          'Data Analysis',
          'Project Management',
        ],
        'skillsToDevelop': [
          'Communication Skills',
          'Problem Solving',
          'Time Management',
          'Technical Writing',
          'Teamwork',
        ],
        'goals': {
          'short':
              'Complete current semester with strong grades and participate in at least one extracurricular project',
          'medium':
              'Gain practical experience through internships and develop expertise in a specialized area',
          'long':
              'Build a professional network and establish a clear career direction based on your interests',
        },
      };
    }
  }

  // Save career plan to Firestore
  static Future<String> saveCareerPlan(CareerPlan careerPlan) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('career_plans')
          .add(careerPlan.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error saving career plan: $e');
      rethrow;
    }
  }

  // Get user's latest career plan
  static Future<CareerPlan?> getLatestCareerPlan(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('career_plans')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return CareerPlan.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting latest career plan: $e');
      return null;
    }
  }

  // Get all career plans for a user
  static Stream<QuerySnapshot> getCareerPlansStream(String userId) {
    return FirebaseFirestore.instance
        .collection('career_plans')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Main function to create a complete career plan
  static Future<CareerPlan> createCareerPlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // 1. Collect user data
    final userData = await collectUserData(user.uid);

    // 2. Create summary
    final userDataSummary = createUserDataSummary(userData);

    // 3. Generate AI-powered career plan
    final aiResponse = await generateCareerPlanWithAI(userDataSummary);

    // 4. Create CareerPlan object
    final careerPlan = CareerPlan(
      id: '', // Will be set after saving
      userId: user.uid,
      careerAdvice: aiResponse['careerAdvice'] ?? '',
      careerPaths: List<String>.from(aiResponse['careerPaths'] ?? []),
      skillsToDevelop: List<String>.from(aiResponse['skillsToDevelop'] ?? []),
      goals: Map<String, String>.from(aiResponse['goals'] ?? {}),
      createdAt: DateTime.now(),
      userDataSummary: userDataSummary,
    );

    // 5. Save to Firestore
    final docId = await saveCareerPlan(careerPlan);

    return CareerPlan(
      id: docId,
      userId: careerPlan.userId,
      careerAdvice: careerPlan.careerAdvice,
      careerPaths: careerPlan.careerPaths,
      skillsToDevelop: careerPlan.skillsToDevelop,
      goals: careerPlan.goals,
      createdAt: careerPlan.createdAt,
      userDataSummary: careerPlan.userDataSummary,
    );
  }
}
