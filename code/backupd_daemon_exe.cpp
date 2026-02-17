#include <filesystem>
namespace fs = std::filesystem;

#include <chrono>
using sys_clock = std::chrono::system_clock;

#include <iostream>
#include <stdexcept>
#include <sstream>
#include <iomanip>
#include <ctime>

#define err(msg) std::runtime_error(msg)

void checkPath(fs::path &source, fs::path &target)
{
	if (!fs::exists(source))
		throw err("source: " + source.string() + " does not exist");
	if (!fs::is_directory(source))
		throw err("source: " + source.string() + " is not directory");
	source = fs::canonical(source);

	if (fs::exists(target))
	{
		if (!fs::is_directory(target))
			throw err("target: " + target.string() + " exists but is not directory");
	}
	else
	{
		fs::create_directories(target);
		std::cout << "target: " << target << " created\n";
	}

	target = fs::canonical(target);
}

void doBackup(const fs::path &source, const fs::path &target)
{
	std::time_t now = sys_clock::to_time_t(sys_clock::now());
	std::stringstream date;
	date << std::put_time(std::localtime(&now), "%d_%m_%Y__%H_%M_%S");

	fs::path backupDir = target / date.str();
	fs::create_directories(backupDir);

	for (const auto &entry : fs::directory_iterator(source))
	{
		fs::copy(
			entry.path(),
			backupDir / entry.path().filename(),
			fs::copy_options::recursive | fs::copy_options::overwrite_existing);
	}

	std::cout << "backup done: " << source << " -> " << backupDir << "\n";
}

int main(int argc, char **argv)
{
	try
	{
		if (argc < 3)
			throw err("backup: too few arguments (need SOURCE and TARGET)");

		fs::path source = argv[1];
		fs::path target = argv[2];

		checkPath(source, target);
		doBackup(source, target);

		return 0;
	}
	catch (const std::exception &e)
	{
		std::cerr << "backupd_daemon_exe error: " << e.what() << "\n";
		return 1;
	}
}
