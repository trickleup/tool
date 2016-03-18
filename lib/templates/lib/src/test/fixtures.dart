part of __projectName__.test;

Iterable<Object> get fixtures => [
      new Post(1, 'Hello world', 'Just hi.', new DateTime.now()),
      new Post(2, "Haven't written here for a while", 'Hi again.',
          new DateTime.now()),
    ];
