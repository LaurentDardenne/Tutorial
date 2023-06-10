﻿
@{
	### Helps.ps1
	Helpsps1Synopsis = 'Helps.ps1 - PowerShell Help Builder'
	Helpsps1Description = @'
	Helps.ps1 - это набор функций позволяющих создавать шаблоны скриптов помощи
	и компилировать из них файлы помощи в формате XML для PowerShell. Помощь
	может быть создана для всего, что поддерживает этот формат: командлеты,
	провайдеры, отдельные скрипты, функции скрипт-модулей, функции скриптов.

	Скрипты помощи выглядят похоже на получаемый текст помощи (почти WYSIWYG).
	В то же время, они - обычные скрипты PowerShell, и это делает многие
	полезные вещи простыми в реализации. Вот один важный пример - локализация
	файлов помощи.

	После загрузки скрипт предоставляет следующие функции:

	Convert-Helps
		Компилирует исходные скрипты помощи в конечные файлы помощи PowerShell.

	Merge-Helps
		Позволяет наследовать помощь дочерних команд из помощи базовых.

	New-Helps
		Создает шаблоны помощи и локализованных данных для команд и провайдеров.

	Test-Helps
		Тестирует примеры кода из помощи, запуская встроенные проверки 'test'.

	СКРИПТ ПОМОЩИ

	Скрипт помощи создает и возвращает таблицы помощи (Hashtable), описывающие
	помощь для команды или провайдера. Скрипт либо его вызывающий должен
	обеспечить доступность команд или провайдеров для постройки помощи.

	Тексты synopsis, description и т.п. могут быть одной строкой или массивом.

	Каждая новая строка скрипта печатается с новой строки в помощи. Строки с
	отступом не форматируются. Последовательности непустых строк без отступа
	соединяются вместе пробелами.

	ТАБЛИЦА ПОМОЩИ КОМАНДЫ

	Обязательные ключи
		command, synopsis.

	description
		По умолчанию берется текст из synopsis.

	sets
		Ключи - имена наборов параметров, данные - комментарии.

	parameters
		Ключи - имена параметров, данные - комментарии.

	examples ... title
		По умолчанию генерируется в виде --- EXAMPLE N ---.

	examples ... code
		[ScriptBlock] или [string].
		[ScriptBlock] тестируется с помощью 'test' кода и Test-Helps.

	examples ... test
		[ScriptBlock].
		$args[0] - это переданный для тестирования скрипт примера.

	ТАБЛИЦА ПОМОЩИ ПРОВАЙДЕРА

	Данные помощи провайдера во многом похожи на данные помощи команд.
	Отличия:

	Обязательные ключи
		provider, synopsis.

	examples
		introduction и code не сливаются вместе, как у команд.

	ПРИМЕРЫ

	Demo\Helps-Help.ps1
		Исходник помощи для Helps.ps1 и его функций.

	Demo\Test-Helps-Help.ps1
		Исчерпывающий пример/тест исходника помощи для команд.

	Demo\TestProvider.dll-Help.ps1
		Исчерпывающий пример/тест исходника помощи для провайдеров.
'@

	### Convert-Helps
	ConvertHelpsSynopsis = 'Конвертирует исходный скрипт помощи в PowerShell файл помощи.'
	ScriptParameter = 'Путь(и) исходного скрипта помощи.'
	OutputParameter = 'Путь создаваемого MAML файла помощи (обычно "ModuleName.dll-Help.xml").'
	ParametersParameter = 'Параметры, передаваемые в исходные скрипты помощи.'
	ConvertHelpsExampleRemarks = @'
Создает файл помощи "temp.xml" из исходного скрипта помощи "Helps-Help.ps1".
'@

	### Test-Helps
	TestHelpsSynopsis = 'Тестирует примеры кода с помощью встроенных проверочных скриптов.'

	### Merge-Helps
	MergeHelpsSynopsis = 'Позволяет наследовать помощь дочерних команд из помощи базовых.'
	MergeHelpsFirst = 'Наследуемая помощь (аналог базового класса, например, базового командлета).'
	MergeHelpsSecond = 'Дополнительные данные помощи (аналог дочернего класса, например, дочернего командлета).'
	MergeHelpsNotes = @'
Эта команда предназначена для комбинирования помощи команд.
Иерархии классов командлетов - довольно частый случай на практике.

Что касается провайдеров, подобная функциональность тоже может реализована, но по запросу.
Пока неизвестно, есть ли к этому практический интерес.
'@
	MergeHelpsDescription = @'
Эта команда обычно используется для слияния таблиц помощи базовых командлетов с
таблицами помощи дочерних командлетов.

Дочерние данные 'inputs', 'outputs', 'examples', 'links' добавляются к базовым.

Дочерние данные 'parameters' сливаются с базовыми.

Другие дочерние данные перезаписывают базовые.
'@
	MergeHelpsOutputs = @'
Таблица, полученная слиянием первой и второй входных таблиц.
Входные таблицы при этом не изменяются.
'@

	### New-Helps
	NewHelpsSynopsis = 'Создает шаблоны помощи и локализованных данных для команд и провайдеров.'
	NewHelpsDescription = @'
Эта команда создает шаблон скрипта помощи для команды или провайдера,
инициализирует некоторые данные и выводит полученный текст кода.
'@
	NewHelpsSetsCommand = 'Создает скрипт помощи для команды.'
	NewHelpsSetsProvider = 'Создает скрипт помощи для провайдера.'
	NewHelpsParametersCommand = 'Имя или объект команды, для которой создается скрипт помощи.'
	NewHelpsParametersProvider = 'Имя или объект провайдера, для которого создается скрипт помощи.'
	NewHelpsParametersIndent = 'Строка используемая для отступов в коде. По умолчанию: "`t".'
	NewHelpsParametersLocalizedData = @'
Требует создания кода со ссылками на локализованные данные и указывает имя
переменной, где они находятся. Начальная структура для локализованных данных
(Hashtable с созданными ключами и пустыми строками) также создается.
'@
	NewHelpsOutputsDescription = 'Строки полученного скрипта помощи.'
	NewHelpsExamplesRemarks = @'
Создает скрипт помощи для команды New-Helps с локализованными данными, которые
хранятся в переменной $data, и выводит полученный код во временный файл temp.ps1.
'@
}
