<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class RendelesVisszaigazolas extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * @param array $rendeles  – a Rendelesek model ->toArray() eredménye
     * @param array $tetelek   – [['nev', 'mennyiseg', 'egysegar'], ...]
     */
    public function __construct(
        public array $rendeles,
        public array $tetelek
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Rendelés visszaigazolás – #' . $this->rendeles['id'],
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.rendeles-visszaigazolas',
        );
    }
}
