

read -p "Ingresa la ip del servidor : " ip

rm -rf lib/env.dart
rm -rf run.bat

echo "const server = '$ip';" >> lib/env.dart
echo "cd ../paycenter && php artisan serve --port=80 --host=$ip" >> run.bat
