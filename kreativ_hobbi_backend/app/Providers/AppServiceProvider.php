<?php

namespace App\Providers;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Support\ServiceProvider;
use Illuminate\Auth\Notifications\VerifyEmail;
use Illuminate\Notifications\Messages\MailMessage;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        ResetPassword::createUrlUsing(function ($user, string $token) {
            return config('app.frontend_url') . '/reset-password?token=' . $token . '&email=' . urlencode($user->email);
        });

        ResetPassword::toMailUsing(function ($notifiable, $token) {
        $url = config('app.frontend_url') . '/reset-password?token=' . $token . '&email=' . urlencode($notifiable->email);

        return (new MailMessage)
            ->subject('Jelszó visszaállítás')
            ->greeting('Helló ' . $notifiable->felhasz_nev . '!')
            ->line('Kaptál egy jelszó visszaállítási kérelmet.')
            ->action('Jelszó visszaállítása', $url)
            ->line('Ez a link 60 percig érvényes.')
            ->line('Ha nem te kérted, hagyd figyelmen kívül ezt az emailt.')
            ->salutation('Üdvözlettel, a Hobbitár csapata');
        });

        VerifyEmail::toMailUsing(function ($notifiable, $url) {
            return (new MailMessage)
                ->subject('Erősítsd meg az email címed')
                ->greeting('Helló ' . $notifiable->felhasz_nev . '!')
                ->line('Kattints a gombra az email cím megerősítéséhez.')
                ->action('Email megerősítése', $url)
                ->line('Ha nem te regisztráltál, hagyd figyelmen kívül ezt az emailt.')
                ->salutation('Üdvözlettel, az Hobbitár csapata');
        });
    }
}
