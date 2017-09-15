template<size_t size, typename T>
memory
{
	std::vector<T> data;
	void put(size_t addr, T value) { data[addr] = value; }
	T get(size_t addr) { return data[addr]; }
};
