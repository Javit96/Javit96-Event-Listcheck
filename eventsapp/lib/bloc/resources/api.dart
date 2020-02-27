import 'dart:async';
import 'package:http/http.dart' show Client;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventsapp/models/classes/task.dart';
import 'dart:convert';
import 'package:eventsapp/models/classes/user.dart';

class ApiProvider
{
  Client client = Client();
  final _apikey = 'your_api_key';

  Future<User> registerUser(String username, String firstname, String lastname, String email, String password) async
  {
    final response = await client
    .post("http://10.0.2.2:5000/api/register",
    
    body: jsonEncode(
      {

        "emailadress" : email,
	      "username" : username,
	      "password" : password,
	      "first_name" : firstname,
	      "last_name" : lastname

      }
    )
    );

  final Map result = json.decode(response.body);
  if (response.statusCode == 201)
  {
    await saveApiKey(result["data"]["api_key"]);
    return User.fromJson(result["data"]);
  }
  else
  {
    throw Exception('Failed to load post');
  }
}

  Future signinUser(String username, String password, String apiKey)async
  {
    final response = await client
          .post("http://10.0.2.2:5000/api/singin",
    headers:
     {
      "Authorization" : apiKey
     },
    body: jsonEncode({
      "username" : username,
      "password" : password,
    }
    )
    );

    final Map result = json.decode(response.body);
    if(response.statusCode == 201)
    {
      await saveApiKey(result["data"]["api_key"]);
    }
    else
    {
      throw Exception('Failed to load post');
    }
  }

  

  Future<List<Task>> getUserTasks(String apiKey) async{
    final response = await client.get("http://10.0.2.2:5000/api/tasks",
    headers: {
      "Authorization" : apiKey
    },
    );
    final Map result = json.decode(response.body);
    if (response.statusCode == 201){
      List<Task> tasks = [];
      for (Map json_ in result["data"]) {
        try {
          tasks.add(Task.fromJson(json_));
        }
        catch(Exception) {
          print(Exception);
        }
      }

    for (Task task in tasks)
    {
      print(task.taskId);
    }

      return tasks;
    } 
    else
    {
      throw Exception('Failed to Load tasks');
    }

  }

  Future addUserTask(String apiKey, String taskName, String deadline) async
  {
    final response = await client
    .post("http://10.0.2.2:5000/api/task",
    headers: {
      "Authorization" : apiKey
    },
    body: jsonEncode({
      "note" : "",
      "completed" : false,
      "deadline" : deadline,
      "reminders" : "",
      "title" : taskName
    })
    );
    if (response.statusCode == 201)
    {
      print("Task added");
    }
    else
    {
      print(json.decode(response.body));
      throw Exception("Failed to load tasks");
    }
  }
  saveApiKey(String api_key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('API_Token', api_key);
   }
}