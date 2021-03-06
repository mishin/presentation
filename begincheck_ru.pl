#!/usr/bin/perl

  # begincheck_ru

  print         "10. Обычный код, работающий во время выполнения.\n";

  END { print   "16.  Так что это конец сказки.\n" }
  INIT { print  " 7. Блоки INIT запускают FIFO непосредственно перед рантаймом (runtime).\n" }
  UNITCHECK {
    print       " 4.   И поэтому перед любым блоком CHECK.\n"
  }
  CHECK { print " 6.   Так что это шестая строка.\n" }

  print         "11.   Она выполняется последовательно, конечно.\n";

  BEGIN { print " 1. BEGIN блоки запускаются FIFO во время компиляции.\n" }
  END { print   "15.   Читайте perlmod для остальной части рассказа.\n" }
  CHECK { print " 5. CHECK блоки запускаются LIFO после всей компиляции.\n" }
  INIT { print  " 8.   Запустить это снова, используя ключ Perl -c.\n" }

  print         "12.   Это анти запутанный код.\n";

  END { print   "14. END блоки запускаются LIFO во время времени выходя из программы.\n" }
  BEGIN { print " 2.   Так что эта линия выходит второй.\n" }
  UNITCHECK {
   print " 3. UNITCHECK блоки запускаются LIFO после того, как каждый файл откомпилируется.\n"
  }
  INIT { print  " 9.   Вы сразу увидите разницу.\n" }

  print         "13.   Это просто _выглядит_ так, как она должна быть запутанным. (It merely _looks_ like it should be confusing.)\n";

  __END__
