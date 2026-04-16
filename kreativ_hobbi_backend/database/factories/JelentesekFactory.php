<?php

namespace Database\Factories;

use App\Models\Jelentes;
use App\Models\Felhasznalok;
use App\Models\Posztok;
use App\Models\Kommentek;
use Illuminate\Database\Eloquent\Factories\Factory;

class JelentesekFactory extends Factory
{
    protected $model = Jelentes::class;

    public function definition(): array
    {
        $tipus = $this->faker->randomElement(['post', 'comment']);

        return [
            'bejelento_id'     => Felhasznalok::inRandomOrder()->value('id'),
            'tipus'            => $tipus,
            'poszt_id'         => $tipus === 'post'    ? Posztok::inRandomOrder()->value('id')    : null,
            'komment_id'       => $tipus === 'comment' ? Kommentek::inRandomOrder()->value('id')  : null,
            'ok'               => $this->faker->randomElement([
                                      'serto', 'spam', '18plus',
                                      'szemelyes', 'jogsertes', 'egyeb',
                                  ]),
            'leiras'           => $this->faker->optional(0.6)->sentence(),
            'statusz'          => 'fuggoben',
            'admin_megjegyzes' => null,
            'kezelo_admin_id'  => null,
            'kezeles_datuma'   => null,
        ];
    }

    // ── Named states ───────────────────────────────────────────

    /** Poszt-bejelentés */
    public function poszt(): static
    {
        return $this->state(fn () => [
            'tipus'      => 'post',
            'poszt_id'   => Posztok::inRandomOrder()->value('id'),
            'komment_id' => null,
        ]);
    }

    /** Komment-bejelentés */
    public function komment(): static
    {
        return $this->state(fn () => [
            'tipus'      => 'comment',
            'komment_id' => Kommentek::inRandomOrder()->value('id'),
            'poszt_id'   => null,
        ]);
    }

    /** Már megoldott (admin kezelte) */
    public function megoldva(): static
    {
        return $this->state(fn () => [
            'statusz'          => 'megoldva',
            'admin_megjegyzes' => $this->faker->sentence(),
            'kezelo_admin_id'  => Felhasznalok::inRandomOrder()->value('id'),
            'kezeles_datuma'   => now()->subHours(rand(1, 72)),
        ]);
    }

    /** Admin megnézte, de még nem döntött */
    public function atnezte(): static
    {
        return $this->state(fn () => [
            'statusz'         => 'atnezte',
            'kezelo_admin_id' => Felhasznalok::inRandomOrder()->value('id'),
            'kezeles_datuma'  => now()->subHours(rand(1, 24)),
        ]);
    }

    /** Elvetett (alaptalan) bejelentés */
    public function elvetve(): static
    {
        return $this->state(fn () => [
            'statusz'          => 'elvetve',
            'admin_megjegyzes' => 'Alaptalannak ítéltük a bejelentést.',
            'kezelo_admin_id'  => Felhasznalok::inRandomOrder()->value('id'),
            'kezeles_datuma'   => now()->subHours(rand(1, 48)),
        ]);
    }
}