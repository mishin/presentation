ack-grep -l --type=perl -i 'head1 NAME'   | xargs perl -pi -E 's/head1 Имя/head1 НАЗВАНИЕ/g'
ack-grep -l --type=perl -i 'head1 NAME' | xargs perl -pi -E 's/head1 NAME/head1 NAME\/НАИМЕНОВАНИЕ/g'
ack-grep -l --type=perl -i 'head1 НАИМЕНОВАНИЕ' | xargs perl -pi -E 's/head1 НАИМЕНОВАНИЕ/head1 NAME\/НАИМЕНОВАНИЕ/g'
+=head1 NAME/НАИМЕНОВАНИЕ
