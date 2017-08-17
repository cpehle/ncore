

namespace ncore {
  namespace register_model {
    class RegisterModel {
      uint64_t input;
      uint64_t value;

    public:
      void tick () {
        value = input;
      }
      void reset() {
        value = 0;
      };

      void in(uint64_t v) {
        input = v;
      };
      uint64_t out() {
        return value;
      };
    }
  }
}
