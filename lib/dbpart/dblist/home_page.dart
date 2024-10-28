

import 'package:flutter/material.dart';
import 'package:new_todo/dbpart/dblist/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  List<Map<String, dynamic>> allNotes = [];
  DbHelper? dbRef;
  int priorityValue = DbHelper.LOW_PRIORITY;

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TODO LIST"),
      ),
      body: 
         allNotes.isNotEmpty
            ? GridView.builder(scrollDirection: Axis.vertical,

              
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6
                ),
                itemCount: allNotes.length,
                itemBuilder: (_, index) {
                  return Card(
                    color: Colors.deepPurpleAccent,
                    margin: const EdgeInsets.all(8),
                    
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:  Column(
                            
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                            
                              Text(
                                'Title: ${allNotes[index][DbHelper.COLUMN_NOTE_TITLE]}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                  'Description: ${allNotes[index][DbHelper.COLUMN_NOTE_DESC]}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white)),
                              Text(
                                  'Priority: ${_getPriorityLabel(allNotes[index][DbHelper.COLUMN_PRIORITY])}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white)),
                              Expanded(
                                
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                       
                                           InkWell(
                                            onTap: () {
                                              titleController.text = allNotes[index]
                                                  [DbHelper.COLUMN_NOTE_TITLE];
                                              descController.text = allNotes[index]
                                                  [DbHelper.COLUMN_NOTE_DESC];
                                              priorityValue =
                                                  allNotes[index][DbHelper.COLUMN_PRIORITY];
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return getBottomSheetWidget(
                                                    isUpdate: true,
                                                    sno: allNotes[index]
                                                        [DbHelper.COLUMN_NOTE_SNO],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.amberAccent,
                                            ),
                                          ),
                                                                     
                                        InkWell(
                                            onTap: () async {
                                              bool check = await dbRef!.deleteNote(
                                                sno: allNotes[index]
                                                    [DbHelper.COLUMN_NOTE_SNO],
                                              );
                                              if (check) {
                                                getNotes();
                                              }
                                            },
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                       
                                      ],
                                    ),
                                  ),
                                ),
                            
                            ],
                          ),
                        ),
                  
                   
                  );
                },
              )
            : const Center(
                child: Text("No Notes Yet!"),
              ),
 
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          titleController.clear();
          descController.clear();
          priorityValue = DbHelper.LOW_PRIORITY;
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return getBottomSheetWidget();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return SingleChildScrollView(
      child: Container(
        color: const Color.fromARGB(255, 0, 4, 255),
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.only(
          top: 16,
          right: 16,
          left: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isUpdate ? "Update Note" : "Add Note",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(178, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10)),
              child: _titleText(),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(178, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10)),
              child: _descText(),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(178, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10)),
              child: _priorityDropdown(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      String title = titleController.text;
                      String desc = descController.text;

                      if (title.isNotEmpty && desc.isNotEmpty) {
                        bool check = isUpdate
                            ? await dbRef!.updateNote(
                                title: title,
                                desc: desc,
                                sno: sno,
                                priority: priorityValue,
                              )
                            : await dbRef!.addNote(
                                title: title,
                                desc: desc,
                                priority: priorityValue,
                              );

                        if (check) {
                          getNotes();
                          Navigator.pop(context);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please fill all fields!")),
                        );
                      }
                    },
                    child: Text(
                      isUpdate ? "Update Note" : "Add Note",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextField _titleText() {
    return TextField(
      controller: titleController,
      decoration: InputDecoration(
        labelText: "Title",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  TextField _descText() {
    return TextField(
      controller: descController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: "Description",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _priorityDropdown() {
    return DropdownButtonFormField<int>(
      value: priorityValue,
      items: [
        DropdownMenuItem(
          value: DbHelper.HIGH_PRIORITY,
          child: Text("High Priority"),
        ),
        DropdownMenuItem(
          value: DbHelper.MEDIUM_PRIORITY,
          child: Text("Medium Priority"),
        ),
        DropdownMenuItem(
          value: DbHelper.LOW_PRIORITY,
          child: Text("Low Priority"),
        ),
      ],
      onChanged: (value) {
        setState(() {
          priorityValue = value!;
        });
      },
      decoration: InputDecoration(
        labelText: "Priority",
        hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case DbHelper.HIGH_PRIORITY:
        return "High";
      case DbHelper.MEDIUM_PRIORITY:
        return "Medium";
      case DbHelper.LOW_PRIORITY:
        return "Low";
      default:
        return "Unknown";
    }
  }
}
